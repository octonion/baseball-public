! parameter(nterms=8,pi=3.1415926,twopi=2.*pi,rad=pi/180.)
! parameter(npts=1000)
! common/path/t(npts),x(nterms,npts)

subroutine dist(range,time)
  parameter(nterms=8,pi=3.1415926,twopi=2.*pi,rad=pi/180.)
  parameter(npts=1000)
  common/path/t(npts),x(nterms,npts)
  do i=1,npts
     if(x(3,i).le.0..and.i.gt.1) go to 250
  end do
  ! linear interpolation to get range
250 frac=x(3,i-1)/(x(3,i-1)-x(3,i))
  d1=sqrt(x(2,i-1)**2+x(1,i-1)**2)
  d2=sqrt(x(2,i)**2+x(1,i)**2)
  range=d1+frac*(d2-d1)
  time=t(i)
  return
end subroutine dist
