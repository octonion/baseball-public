	parameter(noptmax=7)
	parameter(pi=3.1415926,twopi=2.*pi,rad=pi/180,ftm=12./39.37,mtf=1/ftm,rpm=60./twopi)
	parameter(ndmax=200)
	common/data/rhodata(ndmax),vdata(ndmax),thetadata(ndmax),vwind(ndmax)
	common/flag/iflag	
	parameter(const0=5.283e-3,rho0=1.175)
	common/spin/ctht,stht,cphi,sphi

c
c
c	local version of best fit trajectory parameters
c
	common/fitting/cd0,cddot,cdspin,w0,theta0,tau0
c
c	local version of input parameters
c
	common/input/v0,theta,rho,const,vwx,vwy			!in mph,det,kg/m^3,mph,mph

	common/constants/g,radius			!in ft/s^2,ft

	parameter(nterms=8,npts=1000)
	common/initial/xstart(nterms)
	common/path/t(npts),x(nterms,npts)
c
c
	g=32.179		!ft/s^2
	circ=9.125
	radius=circ/twopi/12	!radius of ball in ft
c
c	no wind
	vwx=0.
	vwy=0.
*
*	index i:
*		1,2,3 ==> xi,yi,zi
*		4,5,6 ==> vx,vy,vz
*		7,8 ==> r*wb,r*ws
*
*	wb=backspin rate
*	ws=sidespin rate
*	
c	note on the right-handed coordinate:  
c		z is vertical with positive upward
c		y is catcher-pitcher line
c		x points to catcher's right
c
c	NOTE:  This current version is 2D, so that x=vx=ws=0
c	It is easy to reinstate these to make it full 3D
c
c
c
c	read in parameters for Cd,wb
c
	open(unit=20,file='parameters.csv',status='old')		!input paramters
	read(20,*)
	read(20,*)cd0,cddot,cdspin,w0,theta0,tau0
	close(20)
c
c
c
	open(unit=21,file='TrajectoryCalculatorOutput.csv',status='unknown')		!output file

100	print*
	print*,' OPTIONS:'
	print*,' 1...calculate ball trajectory'
	print*,' 2...calculate range vs. theta at fixed v0'
	print*,' 3...calculate range vs. v0 at fixed theta'
	print*,' 4...calculate range vs. rho at fixed v0,theta'
	print*,' 5...read in external rho,v0,theta and calculate range'
	print*,' 6...calculate range vs. spin at fixed rho,v0,theta'
	print*,' 7...calculate range,tof vs. v0,theta'
	print*
	print*,' enter option: '
	read*,nopt
	if(nopt.eq.0) stop
	if(nopt.lt.1.or.nopt.gt.noptmax) stop
c********************************************
	if(nopt.lt.5) then
		print*,' options 1-4 not yet implemented, choose another'
		go to 100
	endif
c********************************************
	if(nopt.eq.5) then 
		open(unit=20,file='trajectory_input.csv',status='old')				!input data
		read(20,*)			!skip header
		do i=1,ndmax
			read(20,*,end=200)rhodata(i),vdata(i),thetadata(i),vwind(i)
c			print*,rhodata(i),vdata(i),thetadata(i),vwind(i)
		enddo
200		ndata=i-1
		tmax=10.
		write(21,251)		!write header
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
c
c			spin rate=w0 at v0=100. and theta=27.5 and 0 at theta=aparm(5)
c
c			integrate to get trajectory, then distance
c
			call rkdumb(xstart,nterms,0.,tmax,npts)
			call dist(range,time)
			sfact=xstart(7)/(1.467*v0)
			cdi=cd0*(1.+cddot*(100.-v0))*(1.+cdspin*sfact**2)
			write(21,250)rho,v0,theta,spin*rpm,sfact,cdi,vwind(i),range,time
			write(6,250)rho,v0,theta,spin*rpm,sfact,cdi,vwind(i),range,time
		enddo
		go to 100
	elseif(nopt.eq.6) then
		print*,' enter fixed rho,v0,theta,vwnd'
		read*, rho,v0,theta,vwnd
		print*,' enter wmin,wmax,nsteps'
		read*,wmin,wmax,nsteps
		dw=(wmax-wmin)/float(nsteps)
		vwy=vwnd*1.467
		vwx=0.
		tmax=10.
		do i=1,nsteps+1
			const=const0*(rho/rho0)
			spin=(wmin+float(i-1)*dw)/rpm
			xstart(1)=0.
			xstart(2)=2.
			xstart(3)=3.
			xstart(4)=0.
			ctht=cos(theta*rad)
			stht=sin(theta*rad)
			xstart(5)=(v0*1.467)*ctht
			xstart(6)=(v0*1.467)*stht
			cphi=1.
			sphi=1.
			xstart(7)=radius*spin
			xstart(8)=0.
			ctht=cos(theta)
			stht=sin(theta)
			cphi=1.
			sphi=0.

			call rkdumb(xstart,nterms,0.,tmax,npts)
			call dist(range,time)
			sfact=xstart(7)/(1.467*v0)
			cdi=cd0*(1.+cddot*(100.-v0))*(1.+cdspin*sfact**2)
			write(21,250)rho,v0,theta,spin*rpm,sfact,cdi,vwnd,range,time
			write(6,250)rho,v0,theta,spin*rpm,sfact,cdi,vwnd,range,time
		enddo
		go to 100
	elseif(nopt.eq.7) then
		print*,' enter fixed rho,vwind (kg/m^3,mph)'
		read*,rho,vwnd
		const=const0*(rho/rho0)
		vwy=vwnd*1.467
		vwx=0					!2D 
		print*,' enter vmin,vmax,dv (mph)'
		read*,vmin,vmax,dv
		print*,' enter thetamin,thetamax,dtheta (deg)'
		read*,thetamin,thetamax,dtheta
		v0=vmin
		do while(v0.le.vmax)
			theta=thetamin
			do while(theta.le.thetamax)
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
				tmax=10.
				call rkdumb(xstart,nterms,0.,tmax,npts)
				call dist(range,time)
				write(21,252)v0,theta,range,time
				write(6,252)v0,theta,range,time
				theta=theta+dtheta
			enddo
			v0=v0+dv
		enddo
	endif
	go to 100			
c
251	format(' rho, v0, theta, spin, sfact, cdi, vwind, distance, tof')
250	format(f8.3,',',2(f8.1,','),f8.0,',',2(f8.3,','),10(f8.1,','))
252	format(4(f8.3,','))
	close(21)
	stop
	end
c
*
	subroutine derivs(t,x,dxdt)
*
*	Given the values of t and x, returns derivatives dxdt=dv/dt
*	
c
c	local version of fitting parameters
c
	common/fitting/cd0,cddot,cdspin,w0,theta0,tau0
c
c	local version of input parameters
c
	common/input/v0,theta,rho,const,vwx,vwy			!in mph,det,kg/m^3,mph,mph
c
	common/constants/g,radius			!in ft/s^2,ft
	common/spin/ctht,stht,cphi,sphi

c

	dimension x(8),dxdt(8)
	real drag,lift
	parameter(pi=3.1415926,twopi=2.*pi,rad=pi/180,ftm=12./39.37,rpm=60./twopi)
*
*		1,2,4 ==> x,y,z
*		4,5,6 ==> vx,vy,vz
*		7,8 ==> r*wb,r*ws
*
*	NOTE:  this is 2D problem, so x(1),dxdt(1) are both fixed at 0
*
c	
c	vwx,wwy are x,y components of wind speed
c
c	components of radius*spin
c
	rwb=x(7)
	rws=x(8)
	romega=sqrt(rwb**2+rws**2)
	vt=sqrt((x(4)-vwx)**2+(x(5)-vwy)**2+x(6)**2)	!speed of ball
	sfact=romega/vt				!spin factor
c
c	note that spin is pure backspin (i.e, rws=0)
c
	cd=cd0*(1.+cddot*(100.-v0))*(1.+cdspin*sfact**2)
	cl=sfact/(2.32*sfact+0.4)	!Cross prescription
c	print*,cd,cl,sfact,g,x(7),vt
c	pause
	drag=const*cd*vt		!actually drag/(m*vt)
	lift=const*cl*vt		!actually lift/(m*vt)
c
c	components of spin
c	NOTE:  For 2D, ws=0; cphi=1; sphi=0; this means wy=yz=0 and wx=wb
c
	wx1=rwb
	wy1=-rws*stht
	wz=rws*ctht
	wx=wx1*cphi+wy1*sphi
	wy=-wx1*sphi+wy1*cphi
c
c	the preceding five statement assure the the spin vector is normal to the initial velocity vector
c

	liftx=lift*(wy*x(6)-wz*(x(5)-vwy))/romega		!=0 for 2D
	lifty=lift*(wz*(x(4)-vwx)-wx*x(6))/romega
	liftz=lift*(wx*(x(5)-vwy)-wy*(x(4)-vwx))/romega
	dxdt(1)=x(4)							!=0 for 2D
	dxdt(2)=x(5)
	dxdt(3)=x(6)
	dxdt(4)=-drag*(x(4)-vwx)+liftx				!=0 for 2D
	dxdt(5)=-drag*(x(5)-vwy)+lifty
	dxdt(6)=-drag*x(6)+liftz-g
	dxdt(7)=0.								!no spin-down
	dxdt(8)=0.								!no spin-down
	
	return
	end
*
*
	subroutine RK4(Y,DYDX,N,X,H,YOUT)
*
*	Given values for N variables y and their derivatives DYDX known
*	at X, use the fourth-order Runge-Kutta method to advance the
*	solution over an interval H and return the incremented variables
*	as YOUT, which need not be a distinct array from Y.  The user
*	supplies the subroutine DERIVS(X,Y,DYDX) which returns the
*	derivatives DYDX at X
*
*	Routine taken from Numerical Recipes, 15.1, p. 553
*
	parameter (nmax=10)	!set to the maximum number of functions
	dimension Y(N),DYDX(N),YOUT(N),YT(NMAX),DYT(NMAX),DYM(NMAX)
	hh=h*0.5
	h6=h/6.
	xh=x+hh
	do i=1,n				!first step
		yt(i)=y(i)+hh*dydx(i)
	enddo
	call derivs(xh,yt,dyt)			!second step
	do i=1,n
		yt(i)=y(i)+hh*dyt(i)
	enddo
	call derivs(xh,yt,dym)			!third step
	do i=1,n
		yt(i)=y(i)+h*dym(i)
		dym(i)=dyt(i)+dym(i)
	enddo
	call derivs(x+h,yt,dyt)			!fourth step
	do i=1,n
		yout(i)=y(i)+h6*(dydx(i)+dyt(i)+2.*dym(i))
	enddo
	return
	end
*
*
	subroutine rkdumb(vstart,nvar,x1,x2,nstep)
*
*	Starting from initial values VSTART for NVAR functions, known at
*	X1, use fourth-order Runge-Kutta to advance npts equal increments
*	to X2.  The user supplied subroutine DERIVS(X,V,DVDX) evaluates
*	derivatives.  Results are stored in the common block PATH.  Be sure
*	to dimension the common block appropriately
*
*
*	Routine taken from Numerical Recipes, 15.1, p. 554
	common/coeff/cdprime,cm,cl,rey,sfact,vt
*
	parameter(nmax=10)		!set to the maximum number of functions
	parameter(nterms=8)
	parameter(npts=1000)
	common/path/xx(npts),y(nterms,npts) !nterms functions; npts values
	dimension vstart(nvar),v(nmax),dv(nmax)
	do i=1,nvar			!load starting values
		v(i)=vstart(i)
		y(i,1)=v(i)
	enddo
	xx(1)=x1
	x=x1
	h=(x2-x1)/nstep
c	print*,xx(1),y(1,1),y(2,1)
	do k=1,nstep-1			!take nsetp steps
		call derivs(x,v,dv)
		call rk4(v,dv,nvar,x,h,v)
		if(x+h.eq.x)pause 'Stepsize not significant in RKDUMB'
		x=x+h
		xx(k+1)=x		!store intermediate steps
		do i=1,nvar
			y(i,k+1)=v(i)
		enddo
c	
c	diagnostic print statements
c
c		write(6,102)xx(k+1),(y(ii,k+1),ii=1,2),(y(ii,k+1),ii=4,5),
c    1		y(7,k+1),cd,cm
c		write(6,102)cd,cm,cl,sfact,vt,rey
102	format(10(f10.3,1x))

	enddo
	return
	end
*
	subroutine dist(range,time)
	parameter(nterms=8,pi=3.1415926,twopi=2.*pi,rad=pi/180.)
	parameter(npts=1000)
	common/path/t(npts),x(nterms,npts)
	do i=1,npts
		if(x(3,i).le.0..and.i.gt.1) go to 250
	enddo
250   frac=x(3,i-1)/(x(3,i-1)-x(3,i))!linear interpolation to get range
	d1=sqrt(x(2,i-1)**2+x(1,i-1)**2)
	d2=sqrt(x(2,i)**2+x(1,i)**2)
	range=d1+frac*(d2-d1)
	time=t(i)
	return
	end
