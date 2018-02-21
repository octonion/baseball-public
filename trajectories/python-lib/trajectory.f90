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

subroutine trajectory(cd0,cddot,cdspin,w0,theta0,tau0,rhodata,vdata,thetadata,vwind,spin_rpm,sfact,cdi,distance,tof)

  ! Need to eventually enable 'implicit none'
  !implicit none

  ! Original version by Alan Nathan
  ! Modifcations by Chris Long

  use constants, only : pi,twopi,rad,ftm,mtf,rpm,const0,rho0,g,radius
  use specs, only : nterms, nstep;
  
  real, intent(in) :: cd0
  real, intent(in) :: cddot
  real, intent(in) :: cdspin
  real, intent(in) :: w0
  real, intent(in) :: theta0
  real, intent(in) :: tau0
  real, intent(in) :: rhodata
  real, intent(in) :: vdata
  real, intent(in) :: thetadata
  real, intent(in) :: vwind
  real, intent(out) :: spin_rpm
  real, intent(out) :: sfact
  real, intent(out) :: cdi
  real, intent(out) :: distance
  real, intent(out) :: tof

  real, dimension(nstep) :: t
  real, dimension(nterms,nstep) :: x
  real :: xstart(nterms)

  interface rkdumb
     subroutine rkdumb(xx,y,vstart,nvar,x1,x2,nstep,cd0,cddot,cdspin,w0,theta0,tau0,v0,theta,rho,const,vwx,vwy,ctht,stht,cphi,sphi)
       real, dimension(:), intent(out) :: xx
       real, dimension(:,:), intent(out) :: y
       real, dimension(:), intent(in) :: vstart
       integer, intent(in) :: nvar
       real, intent(in) :: x1
       real, intent(out) :: x2
       integer, intent(in) :: nstep
       real, intent(in) :: cd0
       real, intent(in) :: cddot
       real, intent(in) :: cdspin
       real, intent(in) :: w0
       real, intent(in) :: theta0
       real, intent(in) :: tau0
       ! in mph,det,kg/m^3,mph,mph
       real, intent(in) :: v0
       real, intent(in) :: theta
       real, intent(in) :: rho
       real, intent(in) :: const
       real, intent(in) :: vwx
       real, intent(in) :: vwy
       real, intent(in) :: ctht
       real, intent(in) :: stht
       real, intent(in) :: cphi
       real, intent(in) :: sphi
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

  !real :: rhodata,vdata,thetadata,vwind

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

  ! Maximum allowed hangtime in seconds
  tmax=10.0

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

  call rkdumb(t,x,xstart,nterms,0.,tmax,nstep,cd0,cddot,cdspin,w0,theta0,tau0,v0,theta,rho,const,vwx,vwy,ctht,stht,cphi,sphi)

  call dist(t,x,range,time)
  
  sfact=xstart(7)/(1.467*v0)
  cdi=cd0*(1.+cddot*(100.-v0))*(1.+cdspin*sfact**2)

  spin_rpm=spin*rpm
  distance=range
  tof=time
  
end subroutine trajectory

subroutine derivs(t,x,dxdt,cd0,cddot,cdspin,w0,theta0,tau0,v0,theta,rho,const,vwx,vwy,ctht,stht,cphi,sphi)

  use constants

  ! Given the values of t and x, returns derivatives dxdt=dv/dt

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

  subroutine rk4(y,dydx,n,x,h,yout,cd0,cddot,cdspin,w0,theta0,tau0,v0,theta,rho,const,vwx,vwy,ctht,stht,cphi,sphi)

  ! Given values for N variables y and their derivatives DYDX known
  ! at X, use the fourth-order Runge-Kutta method to advance the
  ! solution over an interval H and return the incremented variables
  ! as YOUT, which need not be a distinct array from Y.  The user
  ! supplies the subroutine DERIVS(X,Y,DYDX) which returns the
  ! derivatives DYDX at X

  ! Routine taken from Numerical Recipes, 15.1, p. 553

  ! set to the maximum number of functions

  use specs, only : nterms
  
  real, intent(inout), dimension(:) :: y
  real, intent(in), dimension(:) :: dydx
  integer, intent(in) :: n
  real, intent(in) :: x
  real, intent(in) :: h
  real, intent(inout), dimension(:) :: yout
  real, intent(in) :: cd0
  real, intent(in) :: cddot
  real, intent(in) :: cdspin
  real, intent(in) :: w0
  real, intent(in) :: theta0
  real, intent(in) :: tau0
  real, intent(in) :: v0
  real, intent(in) :: theta
  real, intent(in) :: rho
  real, intent(in) :: const
  real, intent(in) :: vwx
  real, intent(in) :: vwy
  real, intent(in) :: ctht
  real, intent(in) :: stht
  real, intent(in) :: cphi
  real, intent(in) :: sphi
  
  dimension yt(nterms),dyt(nterms),dym(nterms)
  
  !parameter (nmax=10)
  !dimension y(n),dydx(n),yout(n),yt(nmax),dyt(nmax),dym(nmax)
  
  hh=h*0.5
  h6=h/6.
  xh=x+hh
  
  ! first step
  do i=1,n
     yt(i)=y(i)+hh*dydx(i)
  end do
  ! second step
  call derivs(xh,yt,dyt,cd0,cddot,cdspin,w0,theta0,tau0,v0,theta,rho,const,vwx,vwy,ctht,stht,cphi,sphi)
  do i=1,n
     yt(i)=y(i)+hh*dyt(i)
  end do
  ! third step
  call derivs(xh,yt,dym,cd0,cddot,cdspin,w0,theta0,tau0,v0,theta,rho,const,vwx,vwy,ctht,stht,cphi,sphi)
  do i=1,n
     yt(i)=y(i)+h*dym(i)
     dym(i)=dyt(i)+dym(i)
  end do
  ! fourth step
  call derivs(x+h,yt,dyt,cd0,cddot,cdspin,w0,theta0,tau0,v0,theta,rho,const,vwx,vwy,ctht,stht,cphi,sphi)
  do i=1,n
     yout(i)=y(i)+h6*(dydx(i)+dyt(i)+2.*dym(i))
  end do
  return
end subroutine rk4

subroutine rkdumb(xx,y,vstart,nvar,x1,x2,nstep,cd0,cddot,cdspin,w0,theta0,tau0,v0,theta,rho,const,vwx,vwy,ctht,stht,cphi,sphi)

  ! Starting from initial values VSTART for NVAR functions, known at
  ! X1, use fourth-order Runge-Kutta to advance nstep equal increments
  ! to X2.  The user supplied subroutine DERIVS(X,V,DVDX) evaluates
  ! derivatives.  Results are stored in the common block PATH.  Be sure
  ! to dimension the common block appropriately

  ! Routine taken from Numerical Recipes, 15.1, p. 554

  use specs, only : nterms

  real, dimension(:), intent(out) :: xx
  real, dimension(:,:), intent(out) :: y
  real, dimension(:), intent(in) :: vstart
  integer, intent(in) :: nvar
  real, intent(in) :: x1
  real, intent(out) :: x2
  integer, intent(in) :: nstep
  real, intent(in) :: cd0
  real, intent(in) :: cddot
  real, intent(in) :: cdspin
  real, intent(in) :: w0
  real, intent(in) :: theta0
  real, intent(in) :: tau0
  real, intent(in) :: v0
  real, intent(in) :: theta
  real, intent(in) :: rho
  real, intent(in) :: const
  real, intent(in) :: vwx
  real, intent(in) :: vwy
  real, intent(in) :: ctht
  real, intent(in) :: stht
  real, intent(in) :: cphi
  real, intent(in) :: sphi

  dimension v(nvar),dv(nvar)

  interface rk4
     subroutine rk4(y,dydx,n,x,h,yout,cd0,cddot,cdspin,w0,theta0,tau0,v0,theta,rho,const,vwx,vwy,ctht,stht,cphi,sphi)
       real, intent(inout), dimension(:) :: y
       real, intent(in), dimension(:) :: dydx
       integer, intent(in) :: n
       real, intent(in) :: x
       real, intent(in) :: h
       real, intent(inout), dimension(:) :: yout
       real, intent(in) :: cd0
       real, intent(in) :: cddot
       real, intent(in) :: cdspin
       real, intent(in) :: w0
       real, intent(in) :: theta0
       real, intent(in) :: tau0
       ! in mph,det,kg/m^3,mph,mph
       real, intent(in) :: v0
       real, intent(in) :: theta
       real, intent(in) :: rho
       real, intent(in) :: const
       real, intent(in) :: vwx
       real, intent(in) :: vwy
       real, intent(in) :: ctht
       real, intent(in) :: stht
       real, intent(in) :: cphi
       real, intent(in) :: sphi
     end subroutine rk4
  end interface rk4
  
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
     call derivs(x,v,dv,cd0,cddot,cdspin,w0,theta0,tau0,v0,theta,rho,const,vwx,vwy,ctht,stht,cphi,sphi)
     call rk4(v,dv,nvar,x,h,v,cd0,cddot,cdspin,w0,theta0,tau0,v0,theta,rho,const,vwx,vwy,ctht,stht,cphi,sphi)
     
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
