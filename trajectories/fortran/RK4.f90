! parameter (nmax=10)

subroutine RK4(Y,DYDX,N,X,H,YOUT)

  ! Given values for N variables y and their derivatives DYDX known
  ! at X, use the fourth-order Runge-Kutta method to advance the
  ! solution over an interval H and return the incremented variables
  ! as YOUT, which need not be a distinct array from Y.  The user
  ! supplies the subroutine DERIVS(X,Y,DYDX) which returns the
  ! derivatives DYDX at X

  ! Routine taken from Numerical Recipes, 15.1, p. 553

  ! set to the maximum number of functions
  parameter (nmax=10)
  dimension Y(N),DYDX(N),YOUT(N),YT(NMAX),DYT(NMAX),DYM(NMAX)
  
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
end subroutine RK4
