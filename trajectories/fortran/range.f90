program range
  
  ! Original version by Alan Nathan
  ! Modifcations by Chris Long

  parameter(noptmax=7)
  !parameter(pi=3.1415926,twopi=2.*pi,rad=pi/180,ftm=12./39.37,
  !  mtf=1/ftm,rpm=60./twopi)
  parameter(pi=3.1415926)
  parameter(twopi=2.*pi)
  parameter(rad=pi/180,ftm=12./39.37,mtf=1/ftm,rpm=60./twopi)
  parameter(ndmax=200)
	
  real, dimension(1:ndmax)::rhodata,vdata,thetadata,vwind
  common/data/ rhodata,vdata,thetadata,vwind
  common/flag/iflag	
  parameter(const0=5.283e-3,rho0=1.175)
  common/spin/ctht,stht,cphi,sphi

  ! local version of best fit trajectory parameters
  common/fitting/cd0,cddot,cdspin,w0,theta0,tau0

  ! local version of input parameters
  ! in mph,det,kg/m^3,mph,mph
  common/input/v0,theta,rho,const,vwx,vwy

  ! in ft/s^2,ft
  common/constants/g,radius

  parameter(nterms=8,npts=1000)
  common/initial/xstart(nterms)
  common/path/t(npts),x(nterms,npts)

  ! ft/s^2
  g=32.179
  circ=9.125
  ! radius of ball in ft
  radius=circ/twopi/12

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

  ! input paramters
  open(unit=20,file='parameters.csv',status='old')
  read(20,*)
  read(20,*)cd0,cddot,cdspin,w0,theta0,tau0
  close(20)

  ! output file
  !open(unit=21,file='TrajectoryCalculatorOutput.csv',status='unknown')		
  ! Default status should be unknown
  ! output file
  open(unit=21,file='TrajectoryCalculatorOutput.csv')

  open(unit=20,file='trajectory_input.csv',status='old')
  ! input data
  ! skip header
  read(20,*)
  do i=1,ndmax
     read(20,*,end=200)rhodata(i),vdata(i),thetadata(i),vwind(i)
     !print*,rhodata(i),vdata(i),thetadata(i),vwind(i)
  end do
200 ndata=i-1
  tmax=10.
  ! write header
  write(21,251)
  
  do i=1,ndata
     rho=rhodata(i)
     const=const0*(rho/rho0)
     v0=vdata(i)
     theta=thetadata(i)	
     vwy=vwind(i)*1.467
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

     call rkdumb(xstart,nterms,0.,tmax,npts)
     call dist(range,time)
     sfact=xstart(7)/(1.467*v0)
     cdi=cd0*(1.+cddot*(100.-v0))*(1.+cdspin*sfact**2)
     write(21,250)rho,v0,theta,spin*rpm,sfact,cdi,vwind(i),range,time
     write(6,250)rho,v0,theta,spin*rpm,sfact,cdi,vwind(i),range,time
  end do

251 format(' rho, v0, theta, spin, sfact, cdi, vwind, distance, tof')
250 format(f8.3,',',2(f8.1,','),f8.0,',',2(f8.3,','),10(f8.1,','))
  close(21)
  !stop
end program range
