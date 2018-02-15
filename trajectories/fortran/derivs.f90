  type d_traj
     real :: x
     real :: y
     real :: z
     real :: vx
     real :: vy
     real :: vz
     real :: r_wb
     real :: r_ws
  end type d_traj

  ! common/fitting/cd0,cddot,cdspin,w0,theta0,tau0
  ! common/input/v0,theta,rho,const,vwx,vwy
  ! common/constants/g,radius			
  ! common/spin/ctht,stht,cphi,sphi
  ! parameter(pi=3.1415926)
  ! parameter(twopi=2.*pi)
  ! parameter(rad=pi/180,ftm=12./39.37,rpm=60./twopi)
     
subroutine derivs(t,x,dxdt)

  ! Given the values of t and x, returns derivatives dxdt=dv/dt

  ! local version of fitting parameters
  common/fitting/cd0,cddot,cdspin,w0,theta0,tau0

  ! local version of input parameters
  ! in mph,det,kg/m^3,mph,mph
  common/input/v0,theta,rho,const,vwx,vwy
  
  !in ft/s^2,ft
  common/constants/g,radius			
  common/spin/ctht,stht,cphi,sphi

  dimension x(8),dxdt(8)
  real drag,lift
  
  ! Change to constants?
  parameter(pi=3.1415926)
  parameter(twopi=2.*pi)
  parameter(rad=pi/180,ftm=12./39.37,rpm=60./twopi)

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
