trajectory_pars <- list(
  # constants
  mass = 5.125, # oz,
  circumference = 9.125, # in
  beta = 1.217e-4, # 1 / meter
  cd0 = 0.3008,
  cdspin = 0.0292,
  cl0 = 0.583,
  cl1 = 2.333,
  cl2 = 1.120,
  tau = 10000, # seconds
  g_gravity = 32.174,

  # conversions,
  mph_to_fts = 1.467,
  ft_to_m = 0.3048037,
  lbft3_to_kgm3 = 16.01848,
  kgm3_to_lbft3 = 0.06242789,

  # environmental parameters
  vwind = 0, # mph
  phiwind = 0, #deg
  hwind = 0, #ft
  relative_humidity = 50,
  pressure_in_hg = 29.92,
  temperature_f = 70, #F
  elevation_ft= 15, #feet,

  # batted ball parameters
  x0 = 0, # ft
  y0 = 2.0, # ft
  z0 = 3.0, # ft
  spin = 2675, # revs per second
  spin_phi = -18.5, # degrees
  drag_strength = 1, # 1 = full, 0 to disable
  magnus_strength = 1,
  tmp = 1

)

compute_pars <- function(pars) {
  pars$elevation_m = pars$elevation_ft * pars$ft_to_m
  pars$temperature_c = (pars$temperature_f - 32) * 5 / 9
  pars$pressure_mm_hg = pars$pressure_in_hg * 1000/39.37
  pars$RH = pars$relative_humidity
  pars$SVP = 4.5841*exp((18.687-pars$temperature_c/234.5)*pars$temperature_c/(257.14+pars$temperature_c))

  pars$rho = 1.2929 * (273/(pars$temperature_c+273) *
                         (pars$pressure_mm_hg*exp(-pars$beta * pars$elevation_m) - 0.3783*pars$RH*pars$SVP * 0.01) / 760)


  pars$c0 = 0.07182 * pars$rho * pars$kgm3_to_lbft3 * (5.125/pars$mass)*(pars$circumference/9.125)**2

  pars$sidespin = pars$spin * sin(pars$spin_phi * pi/180)
  pars$backspin = pars$spin * cos(pars$spin_phi * pi/180)
  pars$omega = pars$spin * pi / 30
  pars$romega = pars$circumference * pars$omega / (24 * pi)

  pars

}


rk2 <- function(f, xn, tn, h) {
  k1 = h * f(tn, xn)
  k2 = h * f(tn + h/2, xn + k1/2)

  xn_1 = xn + k2
}

rk4 <- function(f, xn, tn, h) {
  k1 = h*f(tn,xn)
  k2 = h*f(tn + h/2, xn + k1/2)
  k3 = h*f(tn + h/2, xn + k2/2)
  k4 = h*f(tn + h, xn + k3)

  xn_1 = xn + k1/6 + k2/3 + k3/3 + k4/6
}

s_fun <- function(t, vw, pars) {
  (pars$romega / vw) * exp(-t *vw /(pars$tau*146.7))
}

cl_fun <- function(t, vw, pars) {
  s = s_fun(t, vw, pars)
  pars$cl2*s/(pars$cl0+pars$cl1*s)
}

cd_fun <- function(t, vw, pars) {
  pars$cd0 + pars$cdspin * (pars$spin * 1e-3)*exp(-t * vw/(pars$tau*146.7))
}


projectile1 = function(v_initial, launch_angle, launch_phi, dt, pars, N=1e4, stop_dim=3, ...) {

  pars$launch_angle = launch_angle
  pars$launch_phi = launch_phi
  pars = compute_pars(pars)

  extra_pars = list(...)
  for (extra_par in names(extra_pars)) {
    pars[[extra_par]] = extra_pars[[extra_par]]
  }

  t0 = 0.0

  phi = pars$launch_phi
  theta = pars$launch_angle

  phi_rad = pars$launch_phi * pi / 180
  theta_rad = pars$launch_angle  * pi / 180

  xc = c(pars$x0, pars$y0, pars$z0)
  vc = v_initial * pars$mph_to_fts * c(cos(theta_rad) * sin(phi_rad), cos(theta_rad) * cos(phi_rad), sin(theta_rad))

  init_stop = as.integer(xc[[stop_dim]] > 0)
  now_stop = as.integer(xc[[stop_dim]] > 0)

  xa = matrix(rep(0, 3 * N), ncol=3)
  va = matrix(rep(0, 3 * N), ncol=3)
  fa = matrix(rep(0, 9 * N), ncol=9)
  ta = matrix(rep(0, 1 * N), ncol=1)
  cda = matrix(rep(0, 3 * N), ncol=3)
  wa = matrix(rep(0, 3 * N), ncol=3)

  i = 0
  while(now_stop == init_stop && i < N) {
    if (i %% 1000 == 0) {
      message(i)
    }

    i = i + 1
    tc = t0 + i*dt
    ta[i,1] = tc

    vx = vc[[1]]
    vy = vc[[2]]
    vz = vc[[3]]
    v = sqrt(vx**2 + vy**2 + vz**2)

    wb = pars$backspin
    ws = pars$sidespin
    wx = (wb * cos(phi * pi/180) - ws * sin(theta * pi / 180) * sin(phi * pi/180)) * pi / 30
    wy = (-wb * sin(phi * pi/180) - ws * sin(theta * pi / 180) * cos(phi * pi/180)) * pi / 30
    wz = (ws * cos(theta * pi/180)) * pi / 30

    wa[i, 1] = wx
    wa[i, 2] = wy
    wa[i, 3] = wz

    cd = cd_fun(tc, v, pars)
    cl = cl_fun(tc, v, pars)
    s = s_fun(tc, v, pars)

    magnus_const = pars$c0 * cl/pars$omega * v
    magnus_const = magnus_const * pars$magnus_strength

    cda[i, 1] = cd
    cda[i, 2] = cl
    cda[i, 3] = s

    drag_const = pars$c0 * cd * v
    drag_const = pars$drag_strength * drag_const
    fx = function(t, x) {
      -drag_const * vx + magnus_const * (wy * vz - wz * vy)
    }

    fy = function(t, x) {
      -drag_const * vy + magnus_const * (-wx * vz + wz * vx)
    }

    fz = function(t, x) {
      -drag_const * vz + magnus_const * (wx * vy - wy * vx) - pars$g_gravity
    }

    gx = function(a, b) {vx}
    gy = function(a, b) {vy}
    gz = function(a, b) {vz}

    vc[[1]] = rk4(fx, vc[[1]], tc, dt)
    vc[[2]] = rk4(fy, vc[[2]], tc, dt)
    vc[[3]] = rk4(fz, vc[[3]], tc, dt)

    xc[[1]] = rk4(gx, xc[[1]], tc, dt)
    xc[[2]] = rk4(gy, xc[[2]], tc, dt)
    xc[[3]] = rk4(gz, xc[[3]], tc, dt)

    #      message(tc, " ", xc[[j]], " ", vc[[j]])
    xa[i, 1:3] = xc
    va[i, 1:3] = vc
    fa[i, 1:9] = c(fx(tc, vc[[1]]), fy(tc, vc[[2]]), fz(tc, vc[[3]]),
                   -drag_const * vx,
                   -drag_const * vy,
                   -drag_const * vz,
                   magnus_const * (wy * vz - vy * wz),
                   magnus_const * (vx * wz - vz * wx),
                   magnus_const * (wx * vy - wy * vx)
                   )
    now_stop = as.integer(xc[[stop_dim]] > 0)

  }

  data.frame(t=ta[1:i,1],
             x=xa[1:i, 1], y=xa[1:i, 2], z=xa[1:i, 3],
             vx=va[1:i, 1], vy=va[1:i, 2], vz=va[1:i, 3],
             ax=fa[1:i, 1], ay=fa[1:i, 2], az=fa[1:i, 3],
             adragx=fa[1:i, 4], adragy=fa[1:i, 5], adragz=fa[1:i, 6],
             aMagx=fa[1:i, 7], aMagy=fa[1:i, 8], aMagz=fa[1:i, 9],
             Cd=cda[1:i, 1], Cl=cda[1:i, 2], S=cda[1:i, 3])
}
