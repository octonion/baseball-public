! parameter(nmax=10)
! parameter(nterms=8)
! parameter(npts=1000)
! common/coeff/cdprime,cm,cl,rey,sfact,vt
! common/path/xx(npts),y(nterms,npts)

subroutine rkdumb(vstart, nvar, x1, x2, nstep)

  ! Starting from initial values VSTART for NVAR functions, known at
  ! X1, use fourth-order Runge-Kutta to advance npts equal increments
  ! to X2.  The user supplied subroutine DERIVS(X,V,DVDX) evaluates
  ! derivatives.  Results are stored in the common block PATH.  Be sure
  ! to dimension the common block appropriately

  ! Routine taken from Numerical Recipes, 15.1, p. 554
  common/coeff/cdprime,cm,cl,rey,sfact,vt

  !set to the maximum number of functions
  parameter(nmax=10)
  parameter(nterms=8)
  parameter(npts=1000)
  !nterms functions; npts values
  common/path/xx(npts),y(nterms,npts)
  dimension vstart(nvar),v(nmax),dv(nmax)
  
  ! load starting values
  do i=1,nvar		
     v(i)=vstart(i)
     y(i,1)=v(i)
  end do
  xx(1)=x1
  x=x1
  h=(x2-x1)/nstep

  ! take nsetp steps
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
