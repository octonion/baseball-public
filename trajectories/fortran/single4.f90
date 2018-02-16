module constants
  real, parameter :: pi=3.1415926
  real, parameter :: twopi=2.*pi
  real, parameter :: rad=pi/180.
  real, parameter :: ftm=12./39.37
  real, parameter :: mtf=1/ftm
  real, parameter :: rpm=60./twopi
  ! ft/s^2
  real, parameter :: g=32.179
  real, parameter :: circ=9.125
  ! radius of ball in ft
  real, parameter :: radius=circ/twopi/12
  real, parameter :: const0=5.283e-3
  real, parameter :: rho0=1.175
end module constants

module specs
  integer, parameter :: nterms=8
  integer, parameter :: nstep=1000
end module specs

program test

  use constants, only : pi,twopi,rad,ftm,mtf,rpm,const0,rho0,g,radius
  use specs, only : nterms, nstep;
  
  ! Need to eventually enable 'implicit none'
  !implicit none

  ! Original version by Alan Nathan
  ! Modifcations by Chris Long

  interface rkdumb
     subroutine rkdumb(xx,y,vstart,nvar,x1,x2,nstep)
       real, dimension(:), intent(out) :: xx
       real, dimension(:,:), intent(out) :: y
       real, dimension(:), intent(in) :: vstart
       integer, intent(in) :: nvar
       real, intent(in) :: x1
       real, intent(out) :: x2
       integer, intent(in) :: nstep
     end subroutine rkdumb
  end interface rkdumb

  interface dist
     subroutine dist(t,x,range,time)
       real, dimension(:), intent(in) :: t
       real, dimension(:,:), intent(in) :: x
       real, intent(out) :: range
       real, intent(out) :: time
     end subroutine dist
  end interface dist

  real :: rhodata,vdata,thetadata,vwind

  !common/path/t(nstep),x(nterms,nstep)
  real, dimension(nstep) :: t
  real, dimension(nterms,nstep) :: x

  ! Not used
  !parameter(noptmax=7)
  !integer, parameter :: noptmax=7
  
  ! Not necessary
  !common/data/ rhodata,vdata,thetadata,vwind
  ! What is this flag used for?
  !common/flag/iflag

  ! Specs
  !parameter(nterms=8,nstep=1000)
  !integer, parameter :: nterms=8
  !integer, parameter :: nstep=1000

  ! Spin
  common/spin/ctht,stht,cphi,sphi

  ! Fitting
  ! local version of best fit trajectory parameters
  common/fitting/cd0,cddot,cdspin,w0,theta0,tau0

  ! Input
  ! local version of input parameters
  ! in mph,det,kg/m^3,mph,mph
  common/input/v0,theta,rho,const,vwx,vwy

  ! ?
  common/initial/xstart(nterms)
  !common/path/t(nstep),x(nterms,nstep)

  ! no wind
  vwx=0.
  vwy=0.

  ! index i:
  !   1,2,3 ==> xi,yi,zi
  !   4,5,6 ==> vx,vy,vz
  !   7,8 ==> r*wb,r*ws

  ! wb=backspin rate
  ! ws=sidespin rate

  ! note on the right-handed coordinate:  
  !   z is vertical with positive upward
  !   y is catcher-pitcher line
  !   x points to catcher's right

  ! NOTE:  This current version is 2D, so that x=vx=ws=0
  ! It is easy to reinstate these to make it full 3D

  ! read in parameters for Cd,wb

  ! cd0, cddot, cdspin, w0, theta0, tau0

  ! input paramters
  open(unit=20,file='parameters.csv',status='old')
  read(20,*)
  read(20,*) cd0, cddot, cdspin, w0, theta0, tau0
  close(20)

  ! output file
  !open(unit=21,file='TrajectoryCalculatorOutput.csv',status='unknown')		
  ! Default status should be unknown
  ! output file
  open(unit=21,file='TrajectoryCalculatorOutput.csv')

  ! rhodata, vdata, thetadata, vwind
  
  open(unit=20,file='trajectory_input.csv',status='old')
  ! input data
  ! skip header
  read(20,*)
  read(20,*) rhodata, vdata, thetadata, vwind
  ndata=1
  tmax=10.
  ! write header
  write(21,251)
  
  rho=rhodata
  const=const0*(rho/rho0)
  v0=vdata
  theta=thetadata
  vwy=vwind*1.467
  vwx=0.
  xstart(1)=0.
  xstart(2)=2.
  xstart(3)=3.
  xstart(4)=0.
  ctht=cos(theta*rad)
  stht=sin(theta*rad)
  xstart(5)=(v0*1.467)*ctht
  xstart(6)=(v0*1.467)*stht
  cphi=1.
  sphi=0.
  spin=(w0/rpm)*(v0/100.)*(theta-theta0)/(27.5-theta0)
  xstart(7)=radius*spin
  xstart(8)=0.

  ! spin rate=w0 at v0=100. and theta=27.5 and 0 at theta=aparm(5)

  ! integrate to get trajectory, then distance

  call rkdumb(t,x,xstart,nterms,0.,tmax,nstep)

  call dist(t,x,range,time)
  
  sfact=xstart(7)/(1.467*v0)
  cdi=cd0*(1.+cddot*(100.-v0))*(1.+cdspin*sfact**2)
  
  write(21,250) rho, v0, theta, spin*rpm, sfact, cdi, vwind, range, time
  write(6,250) rho, v0, theta, spin*rpm, sfact, cdi, vwind, range, time

251 format(' rho, v0, theta, spin, sfact, cdi, vwind, distance, tof')
250 format(f8.3,2(',',f8.1),1(',',f8.0),2(',',f8.3),3(',',f8.1))
  close(21)
  !stop

end program test

subroutine derivs(t,x,dxdt)

  use constants

  ! Given the values of t and x, returns derivatives dxdt=dv/dt

  ! local version of fitting parameters
  common/fitting/cd0,cddot,cdspin,w0,theta0,tau0

  ! local version of input parameters
  ! in mph,det,kg/m^3,mph,mph
  common/input/v0,theta,rho,const,vwx,vwy
  
  common/spin/ctht,stht,cphi,sphi

  dimension x(8),dxdt(8)
  real drag,lift
  
  ! 1,2,4 ==> x,y,z
  ! 4,5,6 ==> vx,vy,vz
  ! 7,8 ==> r*wb,r*ws

  ! NOTE:  this is 2D problem, so x(1),dxdt(1) are both fixed at 0

  ! vwx,wwy are x,y components of wind speed

  ! components of radius*spin

  rwb=x(7)
  rws=x(8)
  romega=sqrt(rwb**2+rws**2)

  ! speed of ball
  vt=sqrt((x(4)-vwx)**2+(x(5)-vwy)**2+x(6)**2)

  ! spin factor
  sfact=romega/vt				

  ! note that spin is pure backspin (i.e, rws=0)

  cd=cd0*(1.+cddot*(100.-v0))*(1.+cdspin*sfact**2)
  ! Cross prescription
  cl=sfact/(2.32*sfact+0.4)
  !print*,cd,cl,sfact,g,x(7),vt
  !pause

  ! actually drag/(m*vt)
  drag=const*cd*vt
  ! actually lift/(m*vt)
  lift=const*cl*vt

  ! components of spin
  ! NOTE:  For 2D, ws=0; cphi=1; sphi=0; this means wy=yz=0 and wx=wb

  wx1=rwb
  wy1=-rws*stht
  wz=rws*ctht
  wx=wx1*cphi+wy1*sphi
  wy=-wx1*sphi+wy1*cphi

  ! the preceding five statement assure the the spin vector is normal
  ! to the initial velocity vector

  !=0 for 2D
  liftx=lift*(wy*x(6)-wz*(x(5)-vwy))/romega
  lifty=lift*(wz*(x(4)-vwx)-wx*x(6))/romega
  liftz=lift*(wx*(x(5)-vwy)-wy*(x(4)-vwx))/romega
  !=0 for 2D
  dxdt(1)=x(4)
  dxdt(2)=x(5)
  dxdt(3)=x(6)
  !=0 for 2D
  dxdt(4)=-drag*(x(4)-vwx)+liftx
  dxdt(5)=-drag*(x(5)-vwy)+lifty
  dxdt(6)=-drag*x(6)+liftz-g
  !no spin-down
  dxdt(7)=0.
  !no spin-down
  dxdt(8)=0.
	
  return
end subroutine derivs

subroutine rk4(y,dydx,n,x,h,yout)

  use specs, only : nterms

  ! Given values for N variables y and their derivatives DYDX known
  ! at X, use the fourth-order Runge-Kutta method to advance the
  ! solution over an interval H and return the incremented variables
  ! as YOUT, which need not be a distinct array from Y.  The user
  ! supplies the subroutine DERIVS(X,Y,DYDX) which returns the
  ! derivatives DYDX at X

  ! Routine taken from Numerical Recipes, 15.1, p. 553

  ! set to the maximum number of functions

  real, intent(in), dimension(:) :: y
  real, intent(in), dimension(:) :: dydx
  integer, intent(in) :: n
  real, intent(in) :: x
  real, intent(in) :: h
  real, intent(out), dimension(:) :: yout
  
  !parameter (nmax=10)
  !dimension y(n),dydx(n),yout(n),yt(nmax),dyt(nmax),dym(nmax)
  dimension yt(nterms),dyt(nterms),dym(nterms)
  
  hh=h*0.5
  h6=h/6.
  xh=x+hh
  
  ! first step
  do i=1,n
     yt(i)=y(i)+hh*dydx(i)
  end do
  ! second step
  call derivs(xh,yt,dyt)
  do i=1,n
     yt(i)=y(i)+hh*dyt(i)
  end do
  ! third step
  call derivs(xh,yt,dym)
  do i=1,n
     yt(i)=y(i)+h*dym(i)
     dym(i)=dyt(i)+dym(i)
  end do
  ! fourth step
  call derivs(x+h,yt,dyt)
  do i=1,n
     yout(i)=y(i)+h6*(dydx(i)+dyt(i)+2.*dym(i))
  end do
  return
end subroutine rk4

subroutine rkdumb(xx,y,vstart,nvar,x1,x2,nstep)

  use specs, only : nterms

  ! Starting from initial values VSTART for NVAR functions, known at
  ! X1, use fourth-order Runge-Kutta to advance nstep equal increments
  ! to X2.  The user supplied subroutine DERIVS(X,V,DVDX) evaluates
  ! derivatives.  Results are stored in the common block PATH.  Be sure
  ! to dimension the common block appropriately

  ! Routine taken from Numerical Recipes, 15.1, p. 554

  interface rk4
     subroutine rk4(y,dydx,n,x,h,yout)
       real, intent(in), dimension(:) :: y
       real, intent(in), dimension(:) :: dydx
       integer, intent(in) :: n
       real, intent(in) :: x
       real, intent(in) :: h
       real, intent(out), dimension(:) :: yout
     end subroutine rk4
  end interface rk4

  real, dimension(:), intent(out) :: xx
  real, dimension(:,:), intent(out) :: y
  real, dimension(:), intent(in) :: vstart
  integer, intent(in) :: nvar
  real, intent(in) :: x1
  real, intent(out) :: x2
  integer, intent(in) :: nstep

  ! Not necessary
  !common/coeff/cdprime,cm,cl,rey,sfact,vt

  !set to the maximum number of functions
  !parameter(nmax=10)
  !parameter(nterms=8)
  !parameter(nstep=1000)
  !nterms functions; nstep values

  ! Can use nvar for nmax
  ! vstart a parameter
  !dimension vstart(nvar),v(nmax),dv(nmax)
  !dimension v(nmax),dv(nmax)
  dimension v(nvar),dv(nvar)
  
  ! load starting values
  do i=1,nvar		
     v(i)=vstart(i)
     y(i,1)=v(i)
  end do
  xx(1)=x1
  x=x1
  h=(x2-x1)/nstep

  ! take nstep steps
  do k=1,nstep-1
     call derivs(x,v,dv)
     call rk4(v,dv,nvar,x,h,v)
     
     ! Commented out - replace with error code
     !if (x+h.eq.x)pause 'Stepsize not significant in RKDUMB'
     x=x+h
     !store intermediate steps
     xx(k+1)=x
     do i=1,nvar
        y(i,k+1)=v(i)
     end do

  end do
  return
end subroutine rkdumb

subroutine dist(t,x,range,time)

  use constants

  real, dimension(:), intent(in) :: t
  real, dimension(:,:), intent(in) :: x
  real, intent(out) :: range
  real, intent(out) :: time

  integer :: nstep
  nstep=size(t)
  
  ! Fortran does not have repeat-until
  do i=1,nstep
     if(x(3,i).le.0..and.i.gt.1) exit
  end do
  
  ! linear interpolation to get range
  frac=x(3,i-1)/(x(3,i-1)-x(3,i))
  d1=sqrt(x(2,i-1)**2+x(1,i-1)**2)
  d2=sqrt(x(2,i)**2+x(1,i)**2)
  range=d1+frac*(d2-d1)
  time=t(i)
  return
end subroutine dist
