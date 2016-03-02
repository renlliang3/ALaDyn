!*****************************************************************************************************!
!             Copyright 2008-2016 Pasquale Londrillo, Stefano Sinigardi, Andrea Sgattoni              !
!*****************************************************************************************************!

!*****************************************************************************************************!
!  This file is part of ALaDyn.                                                                       !
!                                                                                                     !
!  ALaDyn is free software: you can redistribute it and/or modify                                     !
!  it under the terms of the GNU General Public License as published by                               !
!  the Free Software Foundation, either version 3 of the License, or                                  !
!  (at your option) any later version.                                                                !
!                                                                                                     !
!  ALaDyn is distributed in the hope that it will be useful,                                          !
!  but WITHOUT ANY WARRANTY; without even the implied warranty of                                     !
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                                      !
!  GNU General Public License for more details.                                                       !
!                                                                                                     !
!  You should have received a copy of the GNU General Public License                                  !
!  along with ALaDyn.  If not, see <http://www.gnu.org/licenses/>.                                    !
!*****************************************************************************************************!

 module particles
 use precision_def
 use pstruct_data
 use fstruct_data
 use all_param

 implicit none

 real(dp),parameter :: half=0.5,thr=0.75,two_third=2./3.,one_sixth=1./6.
 real(sp),parameter :: shx=3.,shy=3.,shz=3.
 integer(kind=2) :: err_ind

 contains
 !========================================
 subroutine set_hint_pshape(spl,xx,ax,ind)
 integer,intent(in) :: spl
 real(dp),intent(in) :: xx
 real(dp),intent(out) :: ax(0:3)
 integer,intent(out) :: ind
 real(dp) :: sx,sx2,sx3
 !To half-integer grid points
 select case(spl)
 case(1)
  sx=xx+0.5
  ind=int(sx)
  ax(1)=sx-real(ind,dp)
  ax(0)=1.-ax(1)
 case(2)
  ind=int(xx)
  sx=xx-0.5-real(ind,dp)
  sx2=sx*sx
  ax(1)=0.75-sx2
  ax(2)=0.5*(0.25+sx2+sx)
  ax(0)=1.-ax(1)-ax(2)
 case(3)
  ind=int(xx+0.5)
  sx=xx-real(ind,dp)
  sx2=sx*sx
  sx3=sx2*sx
  ax(1)=two_third-sx2+0.5*sx3
  ax(2)=one_sixth+0.5*(sx+sx2-sx3)
  ax(3)=one_sixth*sx3
  ax(0)=1.-ax(1)-ax(2)-ax(3) ! to (i-1/2,i+1/2,i+3/2,i+5/2) half-int
 end select
 end subroutine set_hint_pshape
 !=======================
 subroutine set_int_pshape(spl,xx,ax,ind)
 integer,intent(in) :: spl
 real(dp),intent(in) :: xx
 real(dp),intent(out) :: ax(0:3)
 integer,intent(out) :: ind
 real(dp) :: sx,sx2,sx3
 !To integer grid points
 select case(spl)
 case(1)
  ind=int(xx)
  ax(1)=xx-real(ind,dp)
  ax(0)=1.-ax(1)
 case(2)
  ind=int(xx+0.5)
  sx=xx-real(ind,dp)
  sx2=sx*sx
  ax(1)=0.75-sx2
  ax(2)=0.5*(0.25+sx2+sx)
  ax(0)=1.-ax(1)-ax(2)
 case(3)
  ind=int(xx)
  sx=xx-real(ind,dp)
  sx2=sx*sx
  sx3=sx2*sx
  ax(1)=two_third-sx2+0.5*sx3
  ax(2)=one_sixth+0.5*(sx+sx2-sx3)
  ax(3)=one_sixth*sx3
  ax(0)=1.-ax(1)-ax(2)-ax(3)
 end select
 end subroutine set_int_pshape


 !===========================================
 subroutine set_grid_charge(sp_loc,part,np,ndm,n_st,ic,xmn,ymn,zmn)

 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: part(:,:)
 integer,intent(in) :: np,ndm,n_st,ic
 real(dp),intent(in) :: xmn,ymn,zmn
 real(dp) :: xx,sx,sx2,dvol,wgh
 real(dp) :: ax0(0:3),ay0(0:3),az0(0:3),xp(3)
 integer :: i,j,k,i1,j1,k1,i2,j2,k2,n,ch,spl
 real(sp) :: charge(2),wgh4
 equivalence(charge,wgh)
 !======================
 ax0(0:3)=0.0;ay0(0:3)=0.0
 az0(0:3)=0.0
 spl=2
 select case(ndm)
 case(1)
  j2=1
  do n=1,np
   xp(1)=dx_inv*(sp_loc%part(n)%cmp(1)-xmn)
   wgh=sp_loc%part(n)%cmp(5)
   wgh4=charge(1)*charge(2)
   xx=shx+xp(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)
   ax0(0:2)=wgh4*ax0(0:2)
   i=i-1
   do i1=0,2
    i2=i+i1
    jc(i2,j2,1,ic)=jc(i2,j2,1,ic)+ax0(i1)
   end do
  end do
 case(2)
  do n=1,np
   part(1,n)=dx_inv*(sp_loc%part(n)%cmp(1)-xmn)
   part(2,n)=sp_loc%part(n)%cmp(2)
  end do
  if(n_st==0)then
   do n=1,np
    xp(2)=part(2,n)
    part(2,n)=dy_inv*(xp(2)-ymn)
   end do
  else
   call map2dy_part_sind(np,n_st,2,ymn,part)
  endif
  ch=5
  do n=1,np
   xp(1:2)=part(1:2,n)
   wgh=sp_loc%part(n)%cmp(ch)
   wgh4=charge(1)*charge(2)
   xx=shx+xp(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)
   ax0(0:2)=wgh4*ax0(0:2)
   i=i-1

   xx=shy+xp(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay0(1)=0.75-sx2
   ay0(2)=0.5*(0.25+sx2+sx)
   ay0(0)=1.-ay0(1)-ay0(2)
   j=j-1
   do j1=0,2
    j2=j+j1
    do i1=0,2
     i2=i+i1
     dvol=ax0(i1)*ay0(j1)
     jc(i2,j2,1,ic)=jc(i2,j2,1,ic)+dvol
    end do
   end do
  end do
 case(3)
  ch=7
  do n=1,np
   xp(1)=sp_loc%part(n)%cmp(1)
   part(1,n)=dx_inv*(xp(1)-xmn)
   part(2:3,n)=sp_loc%part(n)%cmp(2:3) ! current y-z positions
  end do
  if(n_st==0)then
   do n=1,np
    xp(2:3)=part(2:3,n)
    part(2,n)=dy_inv*(xp(2)-ymn)
    part(3,n)=dz_inv*(xp(3)-zmn)
   end do
  else
   call map3d_part_sind(part,np,n_st,2,3,ymn,zmn)
  endif
  do n=1,np
   xp(1:3)=part(1:3,n)
   wgh=sp_loc%part(n)%cmp(ch)
   wgh4=charge(1)*charge(2)
   xx=shx+xp(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)
   ax0(0:2)=wgh4*ax0(0:2)

   xx=shy+xp(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay0(1)=0.75-sx2
   ay0(2)=0.5*(0.25+sx2+sx)
   ay0(0)=1.-ay0(1)-ay0(2)

   xx=shz+xp(3)
   k=int(xx+0.5)
   sx=xx-real(k,dp)
   sx2=sx*sx
   az0(1)=0.75-sx2
   az0(2)=0.5*(0.25+sx2+sx)
   az0(0)=1.-az0(1)-az0(2)
   !---------------
   i=i-1
   j=j-1
   k=k-1
   do k1=0,spl
    k2=k+k1
    do j1=0,spl
     j2=j+j1
     dvol=az0(k1)*ay0(j1)
     do i1=0,spl
      i2=i+i1
      jc(i2,j2,k2,ic)=jc(i2,j2,k2,ic)+ax0(i1)*dvol
     end do
    end do
   end do
  end do
  ! particles on[1:n1,1:n2,1:n3]===> data on [0:n1+1,0:n2+1,0:n3+1,1:4]
 end select
 !+++++++++++++++++++++++++++++++
 end subroutine set_grid_charge


 !==========================
 subroutine set_grid_den_energy(sp_loc,part,np,ndm,njc,n_st,xmn,ymn,zmn)

 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: part(:,:)
 integer,intent(in) :: np,ndm,njc,n_st
 real(dp),intent(in) :: xmn,ymn,zmn
 real(dp) :: xx,sx,sx2,dvol,wgh,gam
 real(dp) :: ax0(0:2),ay0(0:2),az0(0:2),xp(3),pp(3)
 integer :: i,j,k,i1,j1,k1,i2,j2,k2,n,ch,spl
 real(sp) :: charge(2)
 equivalence(charge,wgh)
 !======================
 ax0(0:2)=0.0;ay0(0:2)=0.0
 az0(0:2)=0.0
 spl=2
 select case(ndm)
 case(1)
  ch=5
  j2=1
  do n=1,np
   xp(1)=dx_inv*(sp_loc%part(n)%cmp(1)-xmn)
   pp(1:2)=sp_loc%part(n)%cmp(3:4)
   gam=sqrt(pp(1)*pp(1)+pp(2)*pp(2)+1.)
   wgh=sp_loc%part(n)%cmp(ch)
   xx=shx+xp(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)
   ax0(0:2)=charge(1)*ax0(0:2)
   i=i-1
   do i1=0,2
    i2=i+i1
    dvol=ax0(i1)
    jc(i2,j2,1,1)=jc(i2,j2,1,1)+dvol*charge(2)
    jc(i2,j2,1,2)=jc(i2,j2,1,2)+(gam-1.)*dvol
   end do
  end do
 case(2)
  do n=1,np
   part(1,n)=dx_inv*(sp_loc%part(n)%cmp(1)-xmn)
   part(2,n)=sp_loc%part(n)%cmp(2)
  end do
  if(n_st==0)then
   do n=1,np
    xp(2)=part(2,n)
    part(2,n)=dy_inv*(xp(2)-ymn)
   end do
  else
   call map2dy_part_sind(np,n_st,2,ymn,part)
  endif
  if(njc==2)then
   ch=5
   do n=1,np
    xp(1:2)=part(1:2,n)
    pp(1:2)=sp_loc%part(n)%cmp(3:4)
    gam=sqrt(pp(1)*pp(1)+pp(2)*pp(2)+1.)
    wgh=sp_loc%part(n)%cmp(ch)
    xx=shx+xp(1)
    i=int(xx+0.5)
    sx=xx-real(i,dp)
    sx2=sx*sx
    ax0(1)=0.75-sx2
    ax0(2)=0.5*(0.25+sx2+sx)
    ax0(0)=1.-ax0(1)-ax0(2)
    ax0(0:2)=charge(1)*ax0(0:2)
    i=i-1

    xx=shy+xp(2)
    j=int(xx+0.5)
    sx=xx-real(j,dp)
    sx2=sx*sx
    ay0(1)=0.75-sx2
    ay0(2)=0.5*(0.25+sx2+sx)
    ay0(0)=1.-ay0(1)-ay0(2)
    j=j-1
    do j1=0,2
     j2=j+j1
     do i1=0,2
      i2=i+i1
      dvol=ax0(i1)*ay0(j1)

      jc(i2,j2,1,1)=jc(i2,j2,1,1)+dvol*charge(2)
      jc(i2,j2,1,2)=jc(i2,j2,1,2)+(gam-1.)*dvol
     end do
    end do
   end do
  endif
  if(njc==3)then
   ch=7
   do n=1,np
    xp(1:2)=part(1:2,n)
    pp(1:3)=sp_loc%part(n)%cmp(4:6)
    gam=sqrt(pp(1)*pp(1)+pp(2)*pp(2)+pp(3)*pp(3)+1.)
    wgh=sp_loc%part(n)%cmp(ch)

    xx=shx+xp(1)
    i=int(xx+0.5)
    sx=xx-real(i,dp)
    sx2=sx*sx
    ax0(1)=0.75-sx2
    ax0(2)=0.5*(0.25+sx2+sx)
    ax0(0)=1.-ax0(1)-ax0(2)
    ax0(0:2)=charge(1)*ax0(0:2)
    i=i-1

    xx=shy+xp(2)
    j=int(xx+0.5)
    sx=xx-real(j,dp)
    sx2=sx*sx
    ay0(1)=0.75-sx2
    ay0(2)=0.5*(0.25+sx2+sx)
    ay0(0)=1.-ay0(1)-ay0(2)
    j=j-1
    do j1=0,2
     j2=j+j1
     do i1=0,2
      i2=i+i1
      dvol=ax0(i1)*ay0(j1)
      jc(i2,j2,1,1)=jc(i2,j2,1,1)+dvol*charge(2)
      jc(i2,j2,1,2)=jc(i2,j2,1,2)+(gam-1.)*dvol
     end do
    end do
   end do
  endif
 case(3)
  ch=7
  do n=1,np
   xp(1)=sp_loc%part(n)%cmp(1)
   part(1,n)=dx_inv*(xp(1)-xmn)
   part(2:3,n)=sp_loc%part(n)%cmp(2:3) ! current y-z positions
  end do
  if(n_st==0)then
   do n=1,np
    xp(2:3)=part(2:3,n)
    part(2,n)=dy_inv*(xp(2)-ymn)
    part(3,n)=dz_inv*(xp(3)-zmn)
   end do
  else
   call map3d_part_sind(part,np,n_st,2,3,ymn,zmn)
  endif
  do n=1,np
   xp(1:3)=part(1:3,n)
   pp(1:3)=sp_loc%part(n)%cmp(4:6)
   wgh=sp_loc%part(n)%cmp(ch)
   gam=sqrt(pp(1)*pp(1)+pp(2)*pp(2)+pp(3)*pp(3)+1.)
   xx=shx+xp(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)
   ax0(0:2)=charge(1)*ax0(0:2)

   xx=shy+xp(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay0(1)=0.75-sx2
   ay0(2)=0.5*(0.25+sx2+sx)
   ay0(0)=1.-ay0(1)-ay0(2)

   xx=shz+xp(3)
   k=int(xx+0.5)
   sx=xx-real(k,dp)
   sx2=sx*sx
   az0(1)=0.75-sx2
   az0(2)=0.5*(0.25+sx2+sx)
   az0(0)=1.-az0(1)-az0(2)
   !---------------
   i=i-1
   j=j-1
   k=k-1
   do k1=0,spl
    k2=k+k1
    do j1=0,spl
     j2=j+j1
     dvol=az0(k1)*ay0(j1)
     do i1=0,spl
      i2=i+i1
      jc(i2,j2,k2,1)=jc(i2,j2,k2,1)+ax0(i1)*dvol*charge(2)
      jc(i2,j2,k2,2)=jc(i2,j2,k2,2)+(gam-1.)*ax0(i1)*dvol
     end do
    end do
   end do
  end do
  ! particles on[1:n1,1:n2,1:n3]===> data on [0:n1+1,0:n2+1,0:n3+1,1:4]
 end select
 !+++++++++++++++++++++++++++++++
 end subroutine set_grid_den_energy
 !==============================================
 subroutine set_grid_momenta(sp_loc,part,np,ndm,njc,nst,xmn,ymn,zmn)

 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: part(:,:)
 integer,intent(in) :: np,ndm,njc,nst
 real(dp),intent(in) :: xmn,ymn,zmn
 real(dp) :: gam,xx,sx,sx2,dvol,dvol1,dvol2,dvol3,wgh
 real(dp) :: ax0(0:3),ay0(0:3),az0(0:3),xp(3),pp(3)
 integer :: spl,i,j,k,i1,j1,k1,i2,j2,k2,n,ch
 !=============================
 real(sp) :: charge(2)
 equivalence(charge,wgh)
 !======================
 spl=2
 ax0(0:3)=0.0;ay0(0:3)=0.0
 az0(0:3)=0.0
 select case(ndm)
 case(1)
  j2=1
  ch=5
  do n=1,np
   xp(1)=dx_inv*(sp_loc%part(n)%cmp(1)-xmn)
   pp(1:2)=sp_loc%part(n)%cmp(3:4)
   wgh=sp_loc%part(n)%cmp(ch)
   xx=shx+xp(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)
   ax0(0:2)=charge(1)*ax0(0:2)
   i=i-1
   do i1=0,2
    i2=i+i1
    dvol=ax0(i1)
    jc(i2,j2,1,1)=jc(i2,j2,1,1)+pp(1)*dvol
    jc(i2,j2,1,2)=jc(i2,j2,1,2)+pp(2)*dvol
   end do
  end do
 case(2)
  do n=1,np
   part(1,n)=dx_inv*(sp_loc%part(n)%cmp(1)-xmn)
   part(2,n)=sp_loc%part(n)%cmp(2)
  end do
  if(nst==0)then
   do n=1,np
    xp(2)=part(2,n)
    part(2,n)=dy_inv*(xp(2)-ymn)
   end do
  else
   call map2dy_part_sind(np,nst,2,ymn,part)
  endif
  if(njc==2)then
   ch=5
   do n=1,np
    xp(1:2)=part(1:2,n)
    pp(1:2)=sp_loc%part(n)%cmp(3:4)
    gam=sqrt(pp(1)*pp(1)+pp(2)*pp(2)+1.)
    pp(1:2)=pp(1:2)/gam
    wgh=sp_loc%part(n)%cmp(ch)
    xx=shx+xp(1)
    i=int(xx+0.5)
    sx=xx-real(i,dp)
    sx2=sx*sx
    ax0(1)=0.75-sx2
    ax0(2)=0.5*(0.25+sx2+sx)
    ax0(0)=1.-ax0(1)-ax0(2)
    ax0(0:2)=charge(1)*ax0(0:2)
    i=i-1

    xx=shy+xp(2)
    j=int(xx+0.5)
    sx=xx-real(j,dp)
    sx2=sx*sx
    ay0(1)=0.75-sx2
    ay0(2)=0.5*(0.25+sx2+sx)
    ay0(0)=1.-ay0(1)-ay0(2)
    j=j-1
    do j1=0,2
     j2=j+j1
     do i1=0,2
      i2=i+i1
      dvol=ax0(i1)*ay0(j1)
      jc(i2,j2,1,1)=jc(i2,j2,1,1)+pp(1)*dvol
      jc(i2,j2,1,2)=jc(i2,j2,1,2)+pp(2)*dvol
     end do
    end do
   end do
  endif
  if(njc==3)then
   ch=7
   do n=1,np
    xp(1:2)=part(1:2,n)
    pp(1:3)=sp_loc%part(n)%cmp(4:6)
    gam=sqrt(pp(1)*pp(1)+pp(2)*pp(2)+pp(3)*pp(3)+1.)
    pp(1:3)=pp(1:3)/gam
    wgh=sp_loc%part(n)%cmp(ch)

    xx=shx+xp(1)
    i=int(xx+0.5)
    sx=xx-real(i,dp)
    sx2=sx*sx
    ax0(1)=0.75-sx2
    ax0(2)=0.5*(0.25+sx2+sx)
    ax0(0)=1.-ax0(1)-ax0(2)
    ax0(0:2)=charge(1)*ax0(0:2)
    i=i-1

    xx=shy+xp(2)
    j=int(xx+0.5)
    sx=xx-real(j,dp)
    sx2=sx*sx
    ay0(1)=0.75-sx2
    ay0(2)=0.5*(0.25+sx2+sx)
    ay0(0)=1.-ay0(1)-ay0(2)
    j=j-1
    do j1=0,2
     j2=j+j1
     do i1=0,2
      i2=i+i1
      dvol=ax0(i1)*ay0(j1)
      jc(i2,j2,1,1)=jc(i2,j2,1,1)+pp(1)*dvol
      jc(i2,j2,1,2)=jc(i2,j2,1,2)+pp(2)*dvol
      jc(i2,j2,1,3)=jc(i2,j2,1,3)+pp(3)*dvol
     end do
    end do
   end do
  endif

 case(3)
  do n=1,np
   xp(1)=sp_loc%part(n)%cmp(1)
   part(1,n)=dx_inv*(xp(1)-xmn)
   part(2:3,n)=sp_loc%part(n)%cmp(2:3)
  end do
  if(nst==0)then
   do n=1,np
    xp(2:3)=part(2:3,n)
    part(2,n)=dy_inv*(xp(2)-ymn)
    part(3,n)=dz_inv*(xp(3)-zmn)
   end do
  else
   call map3d_part_sind(part,np,nst,2,3,ymn,zmn)
  endif
  ch=7
  do n=1,np
   xp(1:3)=part(1:3,n)
   pp(1:3)=sp_loc%part(n)%cmp(4:6)
   gam=sqrt(1.+pp(1)*pp(1)+pp(2)*pp(2)+pp(3)*pp(3))
   pp(1:3)=pp(1:3)/gam
   wgh=sp_loc%part(n)%cmp(ch)
   xx=shx+xp(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)
   ax0(0:2)=charge(1)*ax0(0:2)

   xx=shy+xp(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay0(1)=0.75-sx2
   ay0(2)=0.5*(0.25+sx2+sx)
   ay0(0)=1.-ay0(1)-ay0(2)

   xx=shz+xp(3)
   k=int(xx+0.5)
   sx=xx-real(k,dp)
   sx2=sx*sx
   az0(1)=0.75-sx2
   az0(2)=0.5*(0.25+sx2+sx)
   az0(0)=1.-az0(1)-az0(2)
   !---------------
   i=i-1
   j=j-1
   k=k-1
   do k1=0,spl
    k2=k+k1
    do j1=0,spl
     j2=j+j1
     dvol=az0(k1)*ay0(j1)
     dvol1=pp(1)*dvol
     dvol2=pp(2)*dvol
     dvol3=pp(3)*dvol
     do i1=0,spl
      i2=i+i1
      jc(i2,j2,k2,1)=jc(i2,j2,k2,1)+ax0(i1)*dvol1
      jc(i2,j2,k2,2)=jc(i2,j2,k2,2)+ax0(i1)*dvol2
      jc(i2,j2,k2,3)=jc(i2,j2,k2,3)+ax0(i1)*dvol3
     end do
    end do
   end do
  end do
  ! particles on[1:n1,1:n2,1:n3]===> data on [0:n1+1,0:n2+1,0:n3+1,1:4]
 end select
 !+++++++++++++++++++++++++++++++
 end subroutine set_grid_momenta
 !=============================
 !========= SECTION FOR ACCELERATION FIELDS ASSIGNEMENT
 !==========================================
 subroutine set_part1d_acc(ef,sp_loc,pt,np,ndf,xmn)

 real(dp),intent(in) :: ef(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,ndf
 real(dp),intent(in) :: xmn

 real(dp) :: xx,sx,sx2
 real(dp) :: axh(0:3),xp1(3)
 real(dp) :: ax1(0:3),ap(6)
 integer :: i,ih,i1,i2,j2,n
 !=====================
 !================================
 select case(ndf)
 case(3)
  j2=1
  do n=1,np
   ap(1:3)=0.0
   xp1(1)=sp_loc%part(n)%cmp(1)    !the current particle positions
   xx=shx+dx_inv*(xp1(1)-xmn)

   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)

   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   i=i-1
   ih=ih-1
   do i1=0,2
    i2=i1+ih
    ap(1)=ap(1)+axh(i1)*ef(i2,j2,1,1)      !Ex(i+1/2)
    ap(3)=ap(3)+axh(i1)*ef(i2,j2,1,3)      !Bz(i+1/2)
    i2=i+i1
    ap(2)=ap(2)+ax1(i1)*ef(i2,j2,1,2)      !Ey(i)
   end do
   pt(1:3,n)=ap(1:3)
  end do
  !========================
 case(6)
  j2=1
  do n=1,np
   ap(1:6)=0.0
   xp1(1)=sp_loc%part(n)%cmp(1)    !the current particle positions
   xx=shx+dx_inv*(xp1(1)-xmn)

   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)     !For fields located on cell centers

   ! axh(1)=1.-sx2
   ! axh(2)=0.5*(sx2+sx)

   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)        !For fields located on node points
   i=i-1
   ih=ih-1
   do i1=0,2
    i2=i1+ih
    ap(1)=ap(1)+axh(i1)*ef(i2,j2,1,1) !Ex
    ap(5)=ap(5)+axh(i1)*ef(i2,j2,1,5) !By
    ap(6)=ap(6)+axh(i1)*ef(i2,j2,1,6) !Bz
   end do
   do i1=0,2
    i2=i+i1
    ap(2)=ap(2)+ax1(i1)*ef(i2,j2,1,2) !Ey
    ap(3)=ap(3)+ax1(i1)*ef(i2,j2,1,3) !Ez
    ap(4)=ap(4)+ax1(i1)*ef(i2,j2,1,4) !Bx
   end do
   pt(1:6,n)=ap(1:6)
  end do
 end select
 end subroutine set_part1d_acc
 !===========================
 subroutine set_part2d_acc(ef,sp_loc,pt,np,ndf,s_ind,xmn,ymn)

 real(dp),intent(in) :: ef(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,ndf,s_ind
 real(dp),intent(in) :: xmn,ymn

 real(dp) :: xx,sx,sx2,dvol,dvol1
 real(dp) :: axh(0:2),ayh(0:2),xp1(3)
 real(dp) :: ax1(0:2),ay1(0:2),ap(6)
 integer :: i,ih,j,jh,i1,j1,i2,j2,n

 !================================
 ! USES quadratic splines along each coordinate
 !=======================================
 ! ndf is the number of field component
 ax1(0:2)=0.0;ay1(0:2)=0.0
 axh(0:2)=0.0;ayh(0:2)=0.0
 do n=1,np
  pt(1:2,n)=sp_loc%part(n)%cmp(1:2) ! the current part positions
  pt(1,n)=dx_inv*(pt(1,n)-xmn)
 end do
 if(s_ind==0)then
  do n=1,np
   pt(2,n)=dy_inv*(pt(2,n)-ymn)
  end do
 else
  call map2dy_part_sind(np,s_ind,2,ymn,pt)
 endif

 select case(ndf)
 case(3)
  do n=1,np
   ap(1:3)=0.0
   xp1(1:2)=pt(1:2,n)
   xx=shx+xp1(1)

   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)

   xx=shy+xp1(2)

   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   jh=int(xx)
   sx=xx-0.5-real(jh,dp)
   sx2=sx*sx
   ayh(1)=0.75-sx2
   ayh(2)=0.5*(0.25+sx2+sx)
   ayh(0)=1.-ayh(1)-ayh(2)

   i=i-1
   j=j-1
   ih=ih-1
   jh=jh-1

   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)
    do i1=0,2
     i2=i1+ih
     dvol1=axh(i1)*dvol
     ap(1)=ap(1)+dvol1*ef(i2,j2,1,1) !Ex(i+1/2,j)
    end do
    j2=jh+j1
    dvol=ayh(j1)
    do i1=0,2
     i2=i+i1
     dvol1=ax1(i1)*dvol
     ap(2)=ap(2)+dvol1*ef(i2,j2,1,2) !Ey(i,j+1/2)
     i2=i1+ih
     dvol1=axh(i1)*dvol
     ap(3)=ap(3)+dvol1*ef(i2,j2,1,3) !Bz(i+1/2,j+1/2)
    end do
   end do
   pt(1:3,n)=ap(1:3)
  end do
  !==============
 case(6)
  !=====================
  do n=1,np
   ap(1:6)=0.0
   xp1(1:2)=pt(1:2,n)
   xx=shx+xp1(1)

   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)

   xx=shy+xp1(2)

   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   jh=int(xx)
   sx=xx-0.5-real(jh,dp)
   sx2=sx*sx
   ayh(1)=0.75-sx2
   ayh(2)=0.5*(0.25+sx2+sx)
   ayh(0)=1.-ayh(1)-ayh(2)

   i=i-1
   j=j-1
   ih=ih-1
   jh=jh-1

   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)
    do i1=0,2
     i2=i1+ih
     dvol1=axh(i1)*dvol
     ap(1)=ap(1)+dvol1*ef(i2,j2,1,1) !Ex(i+1/2,j)
     ap(5)=ap(5)+dvol1*ef(i2,j2,1,5) !By(i+1/2,j)
     i2=i1+i
     dvol1=ax1(i1)*dvol
     ap(3)=ap(3)+dvol1*ef(i2,j2,1,3) !Ez(i,j)
    end do
    j2=jh+j1
    dvol=ayh(j1)
    do i1=0,2
     i2=i+i1
     dvol1=ax1(i1)*dvol
     ap(2)=ap(2)+dvol1*ef(i2,j2,1,2) !Ey(i,j+1/2)
     ap(4)=ap(4)+dvol1*ef(i2,j2,1,4) !Bx(i,j+1/2)
     i2=i1+ih
     dvol1=axh(i1)*dvol
     ap(3)=ap(3)+dvol1*ef(i2,j2,1,3) !Bz(i+1/2,j+1/2)
     ap(6)=ap(6)+dvol1*ef(i2,j2,1,6) !Bz(i+1/2,j+1/2)
    end do
   end do
   pt(1:6,n)=ap(1:6)
  end do
 end select
 !=====================
 end subroutine set_part2d_acc
 !=============================
 subroutine set_part2d_hcell_acc(ef,sp_loc,pt,np,ndf,s_ind,xmn,ymn)

 real(dp),intent(in) :: ef(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,ndf,s_ind
 real(dp),intent(in) :: xmn,ymn

 real(dp) :: xx,sx,sx2,dvol,dvol1
 real(dp) :: axh(0:2),ayh(0:2),xp1(3)
 real(dp) :: ax1(0:2),ay1(0:2),ap(6)
 integer :: i,ih,j,jh,i1,j1,i2,j2,n
 !================================
 ! Uses quadratic or linear shapes depending on staggering
 ! ndf is the number of field component
 ax1(0:2)=0.0;ay1(0:2)=0.0
 axh(0:2)=0.0;ayh(0:2)=0.0
 do n=1,np
  pt(1:2,n)=sp_loc%part(n)%cmp(1:2) ! the current part positions
  pt(1,n)=dx_inv*(pt(1,n)-xmn)
 end do
 if(s_ind==0)then
  do n=1,np
   xp1(2)=pt(2,n)
   pt(2,n)=dy_inv*(xp1(2)-ymn)
  end do
 else
  call map2dy_part_sind(np,s_ind,2,ymn,pt)
 endif

 select case(ndf)     !Field components
 case(3)
  do n=1,np
   ap(1:3)=0.0
   xp1(1:2)=pt(1:2,n)
   xx=shx+xp1(1)

   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   axh(1)=sx+0.5
   axh(0)=1.-axh(1)

   xx=shy+xp1(2)

   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   ayh(1)=sx+0.5
   ayh(0)=1.-ayh(1)

   i=i-1
   j=j-1
   ih=i
   jh=j

   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)
    do i1=0,1
     i2=i1+ih
     dvol1=axh(i1)*dvol
     ap(1)=ap(1)+dvol1*ef(i2,j2,1,1) !Ex(i+1/2,j)
    end do
   end do
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)
    do i1=0,2
     i2=i+i1
     dvol1=ax1(i1)*dvol
     ap(2)=ap(2)+dvol1*ef(i2,j2,1,2) !Ey(i,j+1/2)
    end do
    do i1=0,1
     i2=i1+ih
     dvol1=axh(i1)*dvol
     ap(3)=ap(3)+dvol1*ef(i2,j2,1,3) !Bz(i+1/2,j+1/2)
    end do
   end do
   pt(1:3,n)=ap(1:3)
  end do
  !==============
 case(6)
  !=====================
  do n=1,np
   ap(1:6)=0.0
   xp1(1:2)=pt(1:2,n)
   xx=shx+xp1(1)

   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   axh(1)=sx+0.5
   axh(0)=1.-axh(1)

   xx=shy+xp1(2)

   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   ayh(1)=sx+0.5
   ayh(0)=1.-ayh(1)

   i=i-1
   j=j-1
   ih=i
   jh=j

   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)
    do i1=0,1
     i2=i1+ih
     dvol1=axh(i1)*dvol
     ap(1)=ap(1)+dvol1*ef(i2,j2,1,1) !Ex(i+1/2,j)
     ap(5)=ap(5)+dvol1*ef(i2,j2,1,5) !By(i+1/2,j)
    end do
    do i1=0,2
     i2=i1+i
     dvol1=ax1(i1)*dvol
     ap(3)=ap(3)+dvol1*ef(i2,j2,1,3) !Ez(i,j,k+1/2)
    end do
   end do
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)
    do i1=0,2
     i2=i+i1
     dvol1=ax1(i1)*dvol
     ap(2)=ap(2)+dvol1*ef(i2,j2,1,2) !Ey(i,j+1/2)
     ap(4)=ap(4)+dvol1*ef(i2,j2,1,4) !Bx(i,j+1/2)
    end do
    do i1=0,1
     i2=i1+ih
     dvol1=axh(i1)*dvol
     ap(6)=ap(6)+dvol1*ef(i2,j2,1,6) !Bz(i+1/2,j+1/2)
    end do
   end do
   pt(1:6,n)=ap(1:6)
  end do
 end select
 !=====================
 end subroutine set_part2d_hcell_acc
 !====================================
 subroutine set_part3d_acc(ef,sp_loc,pt,np,s_ind,xmn,ymn,zmn)

 real(dp),intent(in) :: ef(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,s_ind
 real(dp),intent(in) :: xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol
 real(dp) :: axh(0:2),ayh(0:2),xp1(3)
 real(dp) :: ax1(0:2),ay1(0:2),azh(0:2),az1(0:2),ap(6)
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n

 !===============================================
 ! USES quadratic splines along each coordinate
 !====================================
 !=============================================================
 ! particle indexing : i=1,....,nx => weights 1,.....nx+2
 ! Fields data[1:n1+2,1:n2+2,1:n3+2] ax(0)=> data(i), ax(1)=> data(i+1) ax(3)=>data(i+2)
 !===================================================
 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0;azh(0:2)=0.0
 axh(0:2)=0.0;ayh(0:2)=0.0
 do n=1,np
  pt(1:3,n)=sp_loc%part(n)%cmp(1:3) ! the current part positions
  xp1(1)=pt(1,n)
  pt(1,n)=dx_inv*(xp1(1)-xmn)
 end do
 if(s_ind==0)then
  do n=1,np
   xp1(2:3)=pt(2:3,n)
   pt(2,n)=dy_inv*(xp1(2)-ymn)
   pt(3,n)=dz_inv*(xp1(3)-zmn)
  end do
 else
  call map3d_part_sind(pt,np,s_ind,2,3,ymn,zmn)
 endif
 do n=1,np
  ap(1:6)=0.0
  xp1(1:3)=pt(1:3,n)    !the current particle positions
  xx=shx+xp1(1)
  i=int(xx+0.5)
  sx=xx-real(i,dp)
  sx2=sx*sx
  ax1(1)=0.75-sx2
  ax1(2)=0.5*(0.25+sx2+sx)
  ax1(0)=1.-ax1(1)-ax1(2)

  ih=int(xx)
  sx=xx-0.5-real(ih,dp)
  sx2=sx*sx
  axh(1)=0.75-sx2
  axh(2)=0.5*(0.25+sx2+sx)
  axh(0)=1.-axh(1)-axh(2)

  xx=shx+xp1(2)
  j=int(xx+0.5)
  sx=xx-real(j,dp)
  sx2=sx*sx
  ay1(1)=0.75-sx2
  ay1(2)=0.5*(0.25+sx2+sx)
  ay1(0)=1.-ay1(1)-ay1(2)

  jh=int(xx)
  sx=xx-0.5-real(jh,dp)
  sx2=sx*sx
  ayh(1)=0.75-sx2
  ayh(2)=0.5*(0.25+sx2+sx)
  ayh(0)=1.-ayh(1)-ayh(2)

  xx=shz+xp1(3)
  k=int(xx+0.5)
  sx=xx-real(k,dp)
  sx2=sx*sx
  az1(1)=0.75-sx2
  az1(2)=0.5*(0.25+sx2+sx)
  az1(0)=1.-az1(1)-az1(2)

  kh=int(xx)
  sx=xx-0.5-real(kh,dp)
  sx2=sx*sx
  azh(1)=0.75-sx2
  azh(2)=0.5*(0.25+sx2+sx)
  azh(0)=1.-azh(1)-azh(2)

  i=i-1
  j=j-1
  k=k-1

  ih=ih-1
  jh=jh-1
  kh=kh-1
  ! Ex(i+1/2,j,k)
  !==============
  !==============
  ! Ey(i,j+1/2,k)
  !==============
  !==============
  ! Bz(i+1/2,j+1/2,k)
  !==============
  do k1=0,2
   k2=k+k1
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*az1(k1)
    do i1=0,1
     i2=i1+ih
     ap(1)=ap(1)+axh(i1)*dvol*ef(i2,j2,k2,1)
    end do
   end do
   do j1=0,2
    j2=jh+j1
    dvol=ayh(j1)*az1(k1)
    do i1=0,2
     i2=i+i1
     ap(2)=ap(2)+ax1(i1)*dvol*ef(i2,j2,k2,2)
    end do
    do i1=0,2
     i2=i1+ih
     ap(6)=ap(6)+axh(i1)*dvol*ef(i2,j2,k2,6)
    end do
   end do
  end do
  !==============
  ! Bx(i,j+1/2,k+1/2)
  !==============
  !==============
  ! By(i+1/2,j,k+1/2)
  !==============
  !==============
  ! Ez(i,j,k+1/2)
  !==============

  do k1=0,2
   k2=kh+k1
   do j1=0,2
    j2=jh+j1
    dvol=ayh(j1)*azh(k1)
    do i1=0,2
     i2=i1+i
     ap(4)=ap(4)+ax1(i1)*dvol*ef(i2,j2,k2,4)
    end do
   end do
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*azh(k1)
    do i1=0,2
     i2=ih+i1
     ap(5)=ap(5)+axh(i1)*dvol*ef(i2,j2,k2,5)
    end do
    do i1=0,2
     i2=i1+i
     ap(3)=ap(3)+ax1(i1)*dvol*ef(i2,j2,k2,3)
    end do
   end do
  end do
  pt(1:6,n)=ap(1:6)
 end do
 !================================
 end subroutine set_part3d_acc
 !================================
 subroutine set_ion_Efield(ef,sp_loc,pt,np,s_ind,ndm,rionz,dt_loc,xmn,ymn,zmn)

 real(dp),intent(in) :: ef(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,s_ind,ndm,rionz
 real(dp),intent(in) :: dt_loc,xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol, gam
 real(dp) :: axh(0:2),ayh(0:2),xp1(3),pp(3)
 real(dp) :: ax1(0:2),ay1(0:2),azh(0:2),az1(0:2),ap(6)
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n

 !===============================================
 ! Linear shape at half-index quadratic shape at integer index
 !====================================
 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0;azh(0:2)=0.0
 axh(0:2)=0.0;ayh(0:2)=0.0
 !===== enter species positions at t^{n+1} level========
 ! fields are at t^n
 select case(ndm)
 case(2)
  k2=1
  if(rionz >1)then
   do n=1,np
    pp(1:2)=sp_loc%part(n)%cmp(3:4)
    gam=1.+pp(1)*pp(1)+pp(2)*pp(2)
    pp(1:2)=pp(1:2)/sqrt(gam)
    pt(1:2,n)=sp_loc%part(n)%cmp(1:2)-dt_loc*pp(1:2) ! stores t^n part positions
    pt(1,n)=dx_inv*(pt(1,n)-xmn)
   end do
  else
   do n=1,np
    pt(1:2,n)=sp_loc%part(n)%cmp(1:2)
    pt(1,n)=dx_inv*(pt(1,n)-xmn)
   end do
  endif
  if(s_ind==0)then
   do n=1,np
    pt(2,n)=dy_inv*(pt(2,n)-ymn)
   end do
  else
   call map2dy_part_sind(np,s_ind,2,ymn,pt)
  endif
  !==========================
  do n=1,np
   ap(1:2)=0.0
   xp1(1:2)=pt(1:2,n)
   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)

   !axh(1)=sx+0.5
   !axh(0)=1.-axh(1)

   xx=shy+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)
   jh=int(xx)
   sx=xx-0.5-real(jh,dp)
   sx2=sx*sx
   ayh(1)=0.75-sx2
   ayh(2)=0.5*(0.25+sx2+sx)
   ayh(0)=1.-ayh(1)-ayh(2)

   !ayh(1)=sx+0.5
   !ayh(0)=1.-ayh(1)

   i=i-1
   j=j-1

   ih=ih-1
   jh=jh-1
   ! Ex(i+1/2,j,k)
   !==============
   !==============
   ! Ey(i,j+1/2,k)
   !==============
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)
    do i1=0,2
     i2=i1+ih
     ap(1)=ap(1)+axh(i1)*dvol*ef(i2,j2,k2,1)*ef(i2,j2,k2,1)
    end do
   end do
   do j1=0,2
    j2=jh+j1
    dvol=ayh(j1)
    do i1=0,2
     i2=i+i1
     ap(1)=ap(1)+ax1(i1)*dvol*ef(i2,j2,k2,2)*ef(i2,j2,k2,2)
    end do
   end do
   !==============
   pt(5,n)=ap(1)
  end do

 case(3)
  if(rionz >1)then
   do n=1,np
    pp(1:3)=sp_loc%part(n)%cmp(4:6)
    gam=1.+pp(1)*pp(1)+pp(2)*pp(2)+pp(3)*pp(3)
    pp(1:3)=pp(1:3)/sqrt(gam)
    pt(1:3,n)=sp_loc%part(n)%cmp(1:3) -dt_loc*pp(1:3) ! the part positions
    xp1(1)=pt(1,n)
    pt(1,n)=dx_inv*(xp1(1)-xmn)
   end do
  else
   do n=1,np
    pt(1:3,n)=sp_loc%part(n)%cmp(1:3)
    xp1(1)=pt(1,n)
    pt(1,n)=dx_inv*(xp1(1)-xmn)
   end do
  endif
  if(s_ind==0)then
   do n=1,np
    xp1(2:3)=pt(2:3,n)
    pt(2,n)=dy_inv*(xp1(2)-ymn)
    pt(3,n)=dz_inv*(xp1(3)-zmn)
   end do
  else
   call map3d_part_sind(pt,np,s_ind,2,3,ymn,zmn)
  endif
  !==========================
  do n=1,np
   ap(1:3)=0.0
   xp1(1:3)=pt(1:3,n)
   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   axh(1)=sx+0.5
   axh(0)=1.-axh(1)

   xx=shy+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   ayh(1)=sx+0.5
   ayh(0)=1.-ayh(1)

   !kh=int(xx)
   !sx=xx-0.5-real(kh,dp)
   !sx2=sx*sx
   !azh(1)=0.75-sx2
   !azh(2)=0.5*(0.25+sx2+sx)
   !azh(0)=1.-azh(1)-azh(2)
   !kh=kh-1
   xx=shz+xp1(3)
   k=int(xx+0.5)
   sx=xx-real(k,dp)
   sx2=sx*sx
   az1(1)=0.75-sx2
   az1(2)=0.5*(0.25+sx2+sx)
   az1(0)=1.-az1(1)-az1(2)

   azh(1)=sx+0.5
   azh(0)=1.-azh(1)

   i=i-1
   j=j-1
   k=k-1

   ih=i
   jh=j
   kh=k
   ! Ex(i+1/2,j,k)
   !==============
   !==============
   ! Ey(i,j+1/2,k)
   !==============
   do k1=0,2
    k2=k+k1
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*az1(k1)
     do i1=0,1
      i2=i1+ih
      ap(1)=ap(1)+axh(i1)*dvol*ef(i2,j2,k2,1)*ef(i2,j2,k2,1)
     end do
    end do
    do j1=0,1
     j2=jh+j1
     dvol=ayh(j1)*az1(k1)
     do i1=0,2
      i2=i+i1
      ap(1)=ap(1)+ax1(i1)*dvol*ef(i2,j2,k2,2)*ef(i2,j2,k2,2)
     end do
    end do
   end do
   !==============
   ! Ez(i,j,k+1/2)
   !==============
   do k1=0,1
    k2=kh+k1
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*azh(k1)
     do i1=0,2
      i2=i1+i
      ap(1)=ap(1)+ax1(i1)*dvol*ef(i2,j2,k2,3)*ef(i2,j2,k2,3)
     end do
    end do
   end do
   pt(7,n)=ap(1)
  end do
 end select
 !================================
 end subroutine set_ion_Efield

 subroutine set_ion_Ebfield(ef,ef1,sp_loc,pt,np,s_ind,ndm,rionz,dt_loc,xmn,ymn,zmn)

 real(dp),intent(in) :: ef(:,:,:,:),ef1(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,s_ind,ndm,rionz
 real(dp),intent(in) :: dt_loc,xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol, gam,eftot
 real(dp) :: axh(0:2),ayh(0:2),xp1(3),pp(3)
 real(dp) :: ax1(0:2),ay1(0:2),azh(0:2),az1(0:2),ap(6)
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n

 !===============================================
 ! Linear shape at half-index quadratic shape at integer index
 !====================================
 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0;azh(0:2)=0.0
 axh(0:2)=0.0;ayh(0:2)=0.0
 !===== enter species positions at t^{n+1} level========
 ! fields are at t^n
 select case(ndm)
 case(2)
  k2=1
  if(rionz >1)then
   do n=1,np
    pp(1:2)=sp_loc%part(n)%cmp(3:4)
    gam=1.+pp(1)*pp(1)+pp(2)*pp(2)
    pp(1:2)=pp(1:2)/sqrt(gam)
    pt(1:2,n)=sp_loc%part(n)%cmp(1:2)-dt_loc*pp(1:2) ! stores t^n part positions
    pt(1,n)=dx_inv*(pt(1,n)-xmn)
   end do
  else
   do n=1,np
    pt(1:2,n)=sp_loc%part(n)%cmp(1:2)
    pt(1,n)=dx_inv*(pt(3,n)-xmn)
   end do
  endif
  if(s_ind==0)then
   do n=1,np
    pt(2,n)=dy_inv*(pt(4,n)-ymn)
   end do
  else
   call map2dy_part_sind(np,s_ind,2,ymn,pt)
  endif
  !==========================
  do n=1,np
   ap(1:2)=0.0
   xp1(1:2)=pt(1:2,n)
   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)

   !axh(1)=sx+0.5
   !axh(0)=1.-axh(1)

   xx=shy+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)
   jh=int(xx)
   sx=xx-0.5-real(jh,dp)
   sx2=sx*sx
   ayh(1)=0.75-sx2
   ayh(2)=0.5*(0.25+sx2+sx)
   ayh(0)=1.-ayh(1)-ayh(2)

   !ayh(1)=sx+0.5
   !ayh(0)=1.-ayh(1)

   i=i-1
   j=j-1

   ih=ih-1
   jh=jh-1
   ! Ex(i+1/2,j,k)
   !==============
   !==============
   ! Ey(i,j+1/2,k)
   !==============
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)
    do i1=0,2
     i2=i1+ih
     eftot=ef(i2,j2,k2,1)+ef1(i2,j2,k2,1)
     ap(1)=ap(1)+axh(i1)*dvol*eftot*eftot
    end do
   end do
   do j1=0,2
    j2=jh+j1
    dvol=ayh(j1)
    do i1=0,2
     i2=i+i1
     eftot=ef(i2,j2,k2,2)+ef1(i2,j2,k2,2)
     ap(2)=ap(2)+ax1(i1)*dvol*eftot*eftot
    end do
   end do
   !==============
   pt(5,n)=ap(1)+ap(2)
  end do

 case(3)
  if(rionz >1)then
   do n=1,np
    pp(1:3)=sp_loc%part(n)%cmp(4:6)
    gam=1.+pp(1)*pp(1)+pp(2)*pp(2)+pp(3)*pp(3)
    pp(1:3)=pp(1:3)/sqrt(gam)
    pt(1:3,n)=sp_loc%part(n)%cmp(1:3) -dt_loc*pp(1:3) ! the part positions
    xp1(1)=pt(1,n)
    pt(1,n)=dx_inv*(xp1(1)-xmn)
   end do
  else
   do n=1,np
    pt(1:3,n)=sp_loc%part(n)%cmp(1:3)
    pt(1,n)=dx_inv*(pt(1,n)-xmn)
   end do
  endif
  if(s_ind==0)then
   do n=1,np
    xp1(2:3)=pt(2:3,n)
    pt(2,n)=dy_inv*(xp1(2)-ymn)
    pt(3,n)=dz_inv*(xp1(3)-zmn)
   end do
  else
   call map3d_part_sind(pt,np,s_ind,2,3,ymn,zmn)
  endif
  !==========================
  do n=1,np
   ap(1:3)=0.0
   xp1(1:3)=pt(1:3,n)
   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   axh(1)=sx+0.5
   axh(0)=1.-axh(1)

   xx=shy+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   ayh(1)=sx+0.5
   ayh(0)=1.-ayh(1)

   !kh=int(xx)
   !sx=xx-0.5-real(kh,dp)
   !sx2=sx*sx
   !azh(1)=0.75-sx2
   !azh(2)=0.5*(0.25+sx2+sx)
   !azh(0)=1.-azh(1)-azh(2)
   !kh=kh-1
   xx=shz+xp1(3)
   k=int(xx+0.5)
   sx=xx-real(k,dp)
   sx2=sx*sx
   az1(1)=0.75-sx2
   az1(2)=0.5*(0.25+sx2+sx)
   az1(0)=1.-az1(1)-az1(2)

   azh(1)=sx+0.5
   azh(0)=1.-azh(1)

   i=i-1
   j=j-1
   k=k-1

   ih=i
   jh=j
   kh=k
   ! Ex(i+1/2,j,k)
   !==============
   !==============
   ! Ey(i,j+1/2,k)
   !==============
   do k1=0,2
    k2=k+k1
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*az1(k1)
     do i1=0,1
      i2=i1+ih
      eftot=ef(i2,j2,k2,1)+ef1(i2,j2,k2,1)
      ap(1)=ap(1)+axh(i1)*dvol*eftot*eftot
     end do
    end do
    do j1=0,1
     j2=jh+j1
     dvol=ayh(j1)*az1(k1)
     do i1=0,2
      i2=i+i1
      eftot=ef(i2,j2,k2,2)+ef1(i2,j2,k2,2)
      ap(2)=ap(2)+ax1(i1)*dvol*eftot*eftot
     end do
    end do
   end do
   !==============
   ! Ez(i,j,k+1/2)
   !==============
   do k1=0,1
    k2=kh+k1
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*azh(k1)
     do i1=0,2
      i2=i1+i
      eftot=ef(i2,j2,k2,3)+ef1(i2,j2,k2,3)
      ap(3)=ap(3)+ax1(i1)*dvol*eftot*eftot
     end do
    end do
   end do
   pt(7,n)=ap(1)+ap(2)+ap(3)
  end do
 end select
 !================================
 end subroutine set_ion_Ebfield

 subroutine set_ion_two_Ebfield(&
  ef,ef1,ef2,sp_loc,pt,np,s_ind,ndm,rionz,dt_loc,xmn,ymn,zmn)

 real(dp),intent(in) :: ef(:,:,:,:),ef1(:,:,:,:),ef2(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,s_ind,ndm,rionz
 real(dp),intent(in) :: dt_loc,xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol, gam,eftot
 real(dp) :: axh(0:2),ayh(0:2),xp1(3),pp(3)
 real(dp) :: ax1(0:2),ay1(0:2),azh(0:2),az1(0:2),ap(6)
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n

 !===============================================
 ! Linear shape at half-index quadratic shape at integer index
 !====================================
 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0;azh(0:2)=0.0
 axh(0:2)=0.0;ayh(0:2)=0.0
 !===== enter species positions at t^{n+1} level========
 ! fields are at t^n
 select case(ndm)
 case(2)
  k2=1
  if(rionz >1)then
   do n=1,np
    pp(1:2)=sp_loc%part(n)%cmp(3:4)
    gam=1.+pp(1)*pp(1)+pp(2)*pp(2)
    pp(1:2)=pp(1:2)/sqrt(gam)
    pt(3:4,n)=sp_loc%part(n)%cmp(1:2)-dt_loc*pp(1:2) ! stores t^n part positions
    pt(1,n)=dx_inv*(pt(3,n)-xmn)
   end do
  else
   do n=1,np
    pt(3:4,n)=sp_loc%part(n)%cmp(1:2)
    pt(1,n)=dx_inv*(pt(3,n)-xmn)
   end do
  endif
  if(s_ind==0)then
   do n=1,np
    pt(2,n)=dy_inv*(pt(4,n)-ymn)
   end do
  else
   call map2dy_part_sind(np,s_ind,2,ymn,pt)
  endif
  !==========================
  do n=1,np
   ap(1:2)=0.0
   xp1(1:2)=pt(1:2,n)
   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)

   !axh(1)=sx+0.5
   !axh(0)=1.-axh(1)

   xx=shy+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)
   jh=int(xx)
   sx=xx-0.5-real(jh,dp)
   sx2=sx*sx
   ayh(1)=0.75-sx2
   ayh(2)=0.5*(0.25+sx2+sx)
   ayh(0)=1.-ayh(1)-ayh(2)

   !ayh(1)=sx+0.5
   !ayh(0)=1.-ayh(1)

   i=i-1
   j=j-1

   ih=ih-1
   jh=jh-1
   ! Ex(i+1/2,j,k)
   !==============
   !==============
   ! Ey(i,j+1/2,k)
   !==============
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)
    do i1=0,2
     i2=i1+ih
     eftot=ef(i2,j2,k2,1)+ef1(i2,j2,k2,1)+ef2(i2,j2,k2,1)
     ap(1)=ap(1)+axh(i1)*dvol*eftot*eftot
    end do
   end do
   do j1=0,2
    j2=jh+j1
    dvol=ayh(j1)
    do i1=0,2
     i2=i+i1
     eftot=ef(i2,j2,k2,2)+ef1(i2,j2,k2,2)+ef2(i2,j2,k2,2)
     ap(2)=ap(2)+ax1(i1)*dvol*eftot*eftot
    end do
   end do
   !==============
   pt(5,n)=ap(1)+ap(2)
  end do

 case(3)
  if(rionz >1)then
   do n=1,np
    pp(1:3)=sp_loc%part(n)%cmp(4:6)
    gam=1.+pp(1)*pp(1)+pp(2)*pp(2)+pp(3)*pp(3)
    pp(1:3)=pp(1:3)/sqrt(gam)
    pt(1:3,n)=sp_loc%part(n)%cmp(1:3) -dt_loc*pp(1:3) ! the part positions
    xp1(1)=pt(1,n)
    pt(1,n)=dx_inv*(xp1(1)-xmn)
   end do
  else
   do n=1,np
    pt(1:3,n)=sp_loc%part(n)%cmp(1:3)
    xp1(1)=pt(1,n)
    pt(1,n)=dx_inv*(xp1(1)-xmn)
   end do
  endif
  if(s_ind==0)then
   do n=1,np
    xp1(2:3)=pt(2:3,n)
    pt(2,n)=dy_inv*(xp1(2)-ymn)
    pt(3,n)=dz_inv*(xp1(3)-zmn)
   end do
  else
   call map3d_part_sind(pt,np,s_ind,2,3,ymn,zmn)
  endif
  !==========================
  do n=1,np
   ap(1:3)=0.0
   xp1(1:3)=pt(1:3,n)
   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   axh(1)=sx+0.5
   axh(0)=1.-axh(1)

   xx=shy+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   ayh(1)=sx+0.5
   ayh(0)=1.-ayh(1)

   !kh=int(xx)
   !sx=xx-0.5-real(kh,dp)
   !sx2=sx*sx
   !azh(1)=0.75-sx2
   !azh(2)=0.5*(0.25+sx2+sx)
   !azh(0)=1.-azh(1)-azh(2)
   !kh=kh-1
   xx=shz+xp1(3)
   k=int(xx+0.5)
   sx=xx-real(k,dp)
   sx2=sx*sx
   az1(1)=0.75-sx2
   az1(2)=0.5*(0.25+sx2+sx)
   az1(0)=1.-az1(1)-az1(2)

   azh(1)=sx+0.5
   azh(0)=1.-azh(1)

   i=i-1
   j=j-1
   k=k-1

   ih=i
   jh=j
   kh=k
   ! Ex(i+1/2,j,k)
   !==============
   !==============
   ! Ey(i,j+1/2,k)
   !==============
   do k1=0,2
    k2=k+k1
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*az1(k1)
     do i1=0,1
      i2=i1+ih
      eftot=ef(i2,j2,k2,1)+ef1(i2,j2,k2,1)+ef2(i2,j2,k2,1)
      ap(1)=ap(1)+axh(i1)*dvol*eftot*eftot
     end do
    end do
    do j1=0,1
     j2=jh+j1
     dvol=ayh(j1)*az1(k1)
     do i1=0,2
      i2=i+i1
      eftot=ef(i2,j2,k2,2)+ef1(i2,j2,k2,2)+ef2(i2,j2,k2,2)
      ap(2)=ap(2)+ax1(i1)*dvol*eftot*eftot
     end do
    end do
   end do
   !==============
   ! Ez(i,j,k+1/2)
   !==============
   do k1=0,1
    k2=kh+k1
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*azh(k1)
     do i1=0,2
      i2=i1+i
      eftot=ef(i2,j2,k2,3)+ef1(i2,j2,k2,3)+ef2(i2,j2,k2,3)
      ap(3)=ap(3)+ax1(i1)*dvol*eftot*eftot
     end do
    end do
   end do
   pt(7,n)=ap(1)+ap(2)+ap(3)
  end do
 end select
 !================================
 end subroutine set_ion_two_Ebfield
 !==================
 subroutine set_part3d_hcell_acc(ef,sp_loc,pt,np,s_ind,xmn,ymn,zmn)

 real(dp),intent(in) :: ef(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,s_ind
 real(dp),intent(in) :: xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol
 real(dp) :: axh(0:2),ayh(0:2),xp1(3)
 real(dp) :: ax1(0:2),ay1(0:2),azh(0:2),az1(0:2),ap(6)
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n

 !===============================================
 !Staggered shapes
 ! Linear shape at half-index
 ! Quadratic shape at integer index
 !====================================
 !=============================================================
 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0;azh(0:2)=0.0
 axh(0:2)=0.0;ayh(0:2)=0.0

 do n=1,np
  pt(1:3,n)=sp_loc%part(n)%cmp(1:3) ! the current part positions
  xp1(1)=pt(1,n)
  pt(1,n)=dx_inv*(xp1(1)-xmn)
 end do
 if(s_ind==0)then
  do n=1,np
   xp1(2:3)=pt(2:3,n)
   pt(2,n)=dy_inv*(xp1(2)-ymn)
   pt(3,n)=dz_inv*(xp1(3)-zmn)
  end do
 else
  call map3d_part_sind(pt,np,s_ind,2,3,ymn,zmn)
 endif
 !==========================
 do n=1,np
  ap(1:6)=0.0
  xp1(1:3)=pt(1:3,n)
  xx=shx+xp1(1)
  i=int(xx+0.5)
  sx=xx-real(i,dp)
  sx2=sx*sx
  ax1(1)=0.75-sx2
  ax1(2)=0.5*(0.25+sx2+sx)
  ax1(0)=1.-ax1(1)-ax1(2)

  axh(1)=sx+0.5
  axh(0)=1.-axh(1)

  xx=shy+xp1(2)
  j=int(xx+0.5)
  sx=xx-real(j,dp)
  sx2=sx*sx
  ay1(1)=0.75-sx2
  ay1(2)=0.5*(0.25+sx2+sx)
  ay1(0)=1.-ay1(1)-ay1(2)

  ayh(1)=sx+0.5
  ayh(0)=1.-ayh(1)

  xx=shz+xp1(3)
  k=int(xx+0.5)
  sx=xx-real(k,dp)
  sx2=sx*sx
  az1(1)=0.75-sx2
  az1(2)=0.5*(0.25+sx2+sx)
  az1(0)=1.-az1(1)-az1(2)

  azh(1)=sx+0.5
  azh(0)=1.-azh(1)

  i=i-1
  j=j-1
  k=k-1

  ih=i
  jh=j
  kh=k
  ! Ex(i+1/2,j,k)
  !==============
  !==============
  ! Ey(i,j+1/2,k)
  !==============
  !==============
  ! Bz(i+1/2,j+1/2,k)
  !==============
  do k1=0,2
   k2=k+k1
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*az1(k1)
    do i1=0,1
     i2=i1+ih
     ap(1)=ap(1)+axh(i1)*dvol*ef(i2,j2,k2,1)
    end do
   end do
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)*az1(k1)
    do i1=0,2
     i2=i+i1
     ap(2)=ap(2)+ax1(i1)*dvol*ef(i2,j2,k2,2)
    end do
    do i1=0,1
     i2=i1+ih
     ap(6)=ap(6)+axh(i1)*dvol*ef(i2,j2,k2,6)
    end do
   end do
  end do
  !==============
  ! Bx(i,j+1/2,k+1/2)
  !==============
  !==============
  ! By(i+1/2,j,k+1/2)
  !==============
  !==============
  ! Ez(i,j,k+1/2)
  !==============

  do k1=0,1
   k2=kh+k1
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)*azh(k1)
    do i1=0,2
     i2=i1+i
     ap(4)=ap(4)+ax1(i1)*dvol*ef(i2,j2,k2,4)
    end do
   end do
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*azh(k1)
    do i1=0,1
     i2=ih+i1
     ap(5)=ap(5)+axh(i1)*dvol*ef(i2,j2,k2,5)
    end do
    do i1=0,2
     i2=i1+i
     ap(3)=ap(3)+ax1(i1)*dvol*ef(i2,j2,k2,3)
    end do
   end do
  end do
  pt(1:6,n)=ap(1:6)
 end do
 !================================
 end subroutine set_part3d_hcell_acc
 !=================================
 subroutine set_env_interp(av,sp_loc,pt,np,ndm,xmn,ymn,zmn)

 type(species),intent(in) :: sp_loc
 real(dp),intent(in) :: av(:,:,:,:)
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,ndm
 real(dp),intent(in) :: xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol,dvol1,dxe,dye,dze
 real(dp) :: axh(0:2),ayh(0:2),xp1(3)
 real(dp) :: ax1(0:2),ay1(0:2),azh(0:2),az1(0:2),ap(4)
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n

 !===============================================
 ! enters av(1)=|a|^2 envelope at integer grid nodes
 ! exit |a|^2/2 and grad[|a|^2]/2 at the particle positions
 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0
 axh(0:2)=0.0;ayh(0:2)=0.0
 azh(0:2)=0.0

 dxe=dx_inv
 dye=dy_inv
 k2=1
 select case(ndm)
 case(2)               !Also for (z,r) cylindical coordinates
  do n=1,np
   xp1(1)=dx_inv*(sp_loc%part(n)%cmp(1)-xmn) !loc (x) z position
   xp1(2)=dy_inv*(sp_loc%part(n)%cmp(2)-ymn) !loc (y) r position

   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)

   xx=shy+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   jh=int(xx)
   sx=xx-0.5-real(jh,dp)
   sx2=sx*sx
   ayh(1)=0.75-sx2
   ayh(2)=0.5*(0.25+sx2+sx)
   ayh(0)=1.-ayh(1)-ayh(2)

   i=i-1
   j=j-1

   ih=ih-1
   jh=jh-1
   ap=0.0
   !==========================
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)
    do i1=0,2
     i2=i1+ih
     dvol1=dvol*axh(i1)
     ap(1)=ap(1)+dvol1*(av(i2+1,j2,k2,1)-av(i2,j2,k2,1))
    end do
    do i1=0,2
     i2=i1+i
     ap(3)=ap(3)+ax1(i1)*dvol*av(i2,j2,k2,1)   !the p-assigned |a|^2/2 field
    end do
    j2=jh+j1
    dvol=ayh(j1)
    do i1=0,2
     i2=i+i1
     dvol1=dvol*ax1(i1)
     ap(2)=ap(2)+dvol1*(av(i2,j2+1,k2,1)-av(i2,j2,k2,1))
    end do
   end do
   !=========================
   ap(1)=dxe*ap(1)   !p-assigned grad_x
   ap(2)=dye*ap(2)   !p-assigned grad_y
   pt(1:3,n)=ap(1:3)
  end do
  !========================
 case(3)
  dxe=dx_inv
  dye=dy_inv
  dze=dz_inv
  !==========================
  do n=1,np
   ap=0.0
   xp1(1)=dx_inv*(sp_loc%part(n)%cmp(1)-xmn) !loc x position
   xp1(2)=dy_inv*(sp_loc%part(n)%cmp(2)-ymn) !loc y position
   xp1(3)=dz_inv*(sp_loc%part(n)%cmp(3)-zmn) !loc z position

   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)

   xx=shy+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   jh=int(xx)
   sx=xx-0.5-real(jh,dp)
   sx2=sx*sx
   ayh(1)=0.75-sx2
   ayh(2)=0.5*(0.25+sx2+sx)
   ayh(0)=1.-ayh(1)-ayh(2)

   xx=shz+xp1(3)
   k=int(xx+0.5)
   sx=xx-real(k,dp)
   sx2=sx*sx
   az1(1)=0.75-sx2
   az1(2)=0.5*(0.25+sx2+sx)
   az1(0)=1.-az1(1)-az1(2)

   kh=int(xx)
   sx=xx-0.5-real(kh,dp)
   sx2=sx*sx
   azh(1)=0.75-sx2
   azh(2)=0.5*(0.25+sx2+sx)
   azh(0)=1.-azh(1)-azh(2)

   i=i-1
   j=j-1
   k=k-1

   ih=ih-1
   jh=jh-1
   kh=kh-1
   !==========================
   ap=0.0
   do k1=0,2
    k2=k+k1
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*az1(k1)
     do i1=0,2
      i2=i1+ih
      dvol1=dvol*axh(i1)
      ap(1)=ap(1)+dvol1*(av(i2+1,j2,k2,1)-av(i2,j2,k2,1))
      i2=i1+i
      ap(4)=ap(4)+ax1(i1)*dvol*av(i2,j2,k2,1)!t^n p-assigned env field
     end do
    end do
    do j1=0,2
     j2=jh+j1
     dvol=ayh(j1)*az1(k1)
     do i1=0,2
      i2=i+i1
      dvol1=dvol*ax1(i1)
      ap(2)=ap(2)+dvol1*(av(i2,j2+1,k2,1)-av(i2,j2,k2,1))
     end do
    end do
    k2=kh+k1
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*azh(k1)
     do i1=0,2
      dvol1=dvol*ax1(i1)
      ap(3)=ap(3)+dvol1*(av(i2,j2,k2+1,1)-av(i2,j2,k2,1))
     end do
    end do
   end do
   ap(1)=dxe*ap(1)
   ap(2)=dye*ap(2)
   ap(3)=dze*ap(3)
   !=================================
   pt(1:4,n)=ap(1:4)
  end do
 end select
 end subroutine set_env_interp

 subroutine set_env_acc(ef,av,sp_loc,pt,np,ndm,dt_loc,xmn,ymn,zmn)

 real(dp),intent(in) :: ef(:,:,:,:)
 real(dp),intent(inout) :: av(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,ndm
 real(dp),intent(in) :: dt_loc,xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol,dvol1,gam2,wgh
 real(dp) :: axh(0:2),ayh(0:2),up(3),xp1(3)
 real(dp) :: ax1(0:2),ay1(0:2),azh(0:2),az1(0:2),ap(12)
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n
 real(dp) :: a1,b1,gam,gamp_new,dth
 !===============================================
 real(sp) :: charge(2)
 equivalence(charge,wgh)
 !===============================================
 ! Linear shape for fields at half-index quadratic shape for fields
 !                         at integer index
 !====================================
 !=============================================================
 !   particle  indexing : i=1,....,nx => weights 1,.....nx+2
 !   Fields data[1:n1+2,1:n2+2,1:n3+2] ax(0)=> data(i), ax(1)=> data(i+1)
 !                                     ax(2)=>data(i+2)
 !===================================================
 ! enters av(1)=|a|^2/2 envelope at integer grid nodes
 ! exit total Lorentz force and velocities
 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0
 axh(0:2)=0.0;ayh(0:2)=0.0
 azh(0:2)=0.0

 k2=1
 dth=0.5*dt_loc
 select case(ndm)
 case(2)
  !================== Works also for (z,r) Pz,Pr cylindrical coordinates

  do n=1,np
   ap=0.0
   xp1(1:2)=sp_loc%part(n)%cmp(1:2)    !the current particle positions
   up(1:2)=sp_loc%part(n)%cmp(3:4)    !the current particle  momenta
   wgh=sp_loc%part(n)%cmp(5)          !the current particle  weight
   xx=shx+dx_inv*(xp1(1)-xmn)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)

   !axh(1)=sx+0.5
   !axh(0)=1.-axh(1)

   xx=shy+dy_inv*(xp1(2)-ymn)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   jh=int(xx)
   sx=xx-0.5-real(jh,dp)
   sx2=sx*sx
   ayh(1)=0.75-sx2
   ayh(2)=0.5*(0.25+sx2+sx)
   ayh(0)=1.-ayh(1)-ayh(2)

   !ayh(1)=sx+0.5
   !ayh(0)=1.-ayh(1)

   i=i-1
   j=j-1

   ih=ih-1
   jh=jh-1
   !==========================
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)
    do i1=0,2
     i2=i1+ih
     dvol1=dvol*axh(i1)
     ap(1)=ap(1)+dvol1*ef(i2,j2,k2,1)
     ap(4)=ap(4)+dvol1*av(i2,j2,k2,2)   !D_x|A|^2/4
    end do
    do i1=0,2
     i2=i1+i
     ap(6)=ap(6)+ax1(i1)*dvol*av(i2,j2,k2,1)!the p-assigned |A|^2/2 env field
    end do
   end do
   do j1=0,2
    j2=jh+j1
    dvol=ayh(j1)
    do i1=0,2
     i2=i+i1
     dvol1=dvol*ax1(i1)
     ap(2)=ap(2)+dvol1*ef(i2,j2,k2,2)
     ap(5)=ap(5)+dvol1*av(i2,j2,k2,3)
    end do
    do i1=0,2
     i2=i1+ih
     ap(3)=ap(3)+axh(i1)*dvol*ef(i2,j2,k2,3)
    end do
   end do
   !=========================
   gam2=1.+up(1)*up(1)+up(2)*up(2)+ap(6)
   !==================== solves a cubic equation gam^3=Agam+B
   a1=-dot_product(ap(1:2),up(1:2))
   b1=-dot_product(ap(4:5),up(1:2))
   gam=sqrt(gam2)
   gamp_new=gam+dth*(gam*a1+b1)/gam2

   ap(3:5)=ap(3:5)/gamp_new
   pt(1,n)=ap(1)+0.5*ap(4)
   pt(2,n)=ap(2)+0.5*ap(5)
   pt(3,n)=ap(3)            !E+F_{env}
   pt(1:3,n)=charge(2)*pt(1:3,n)
   pt(5,n)=charge(1)/gamp_new
  end do
  !========================
 case(3)
  do n=1,np
   ap=0.0
   xp1(1:3)=sp_loc%part(n)%cmp(1:3)   !the current particle positions
   up(1:3)=sp_loc%part(n)%cmp(4:6)    !the current particle  momenta
   wgh=sp_loc%part(n)%cmp(7)          !the current particle (weight,charge)
   xx=shx+dx_inv*(xp1(1)-xmn)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   !ih=int(xx)
   !sx=xx-0.5-real(ih,dp)
   !sx2=sx*sx
   !axh(1)=0.75-sx2
   !axh(2)=0.5*(0.25+sx2+sx)
   !axh(0)=1.-axh(1)-axh(2)

   axh(1)=sx+0.5
   axh(0)=1.-axh(1)

   xx=shy+dy_inv*(xp1(2)-ymn)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)


   ayh(1)=sx+0.5
   ayh(0)=1.-ayh(1)

   xx=shz+dz_inv*(xp1(3)-zmn)
   k=int(xx+0.5)
   sx=xx-real(k,dp)
   sx2=sx*sx
   az1(1)=0.75-sx2
   az1(2)=0.5*(0.25+sx2+sx)
   az1(0)=1.-az1(1)-az1(2)


   azh(1)=sx+0.5
   azh(0)=1.-azh(1)

   i=i-1
   j=j-1
   k=k-1

   ih=i
   jh=j
   kh=k
   !==========================
   do k1=0,2
    k2=k+k1
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*az1(k1)
     do i1=0,2
      i2=i1+i
      ap(10)=ap(10)+ax1(i1)*dvol*av(i2,j2,k2,1)!t^n p-assigned a!^2/2 field
     end do
     do i1=0,1
      i2=i1+ih
      dvol1=dvol*axh(i1)
      ap(1)=ap(1)+dvol1*ef(i2,j2,k2,1)
      ap(7)=ap(7)+dvol1*av(i2,j2,k2,2)
     end do
    end do
    do j1=0,1
     j2=jh+jh
     dvol=ayh(j1)*az1(k1)
     do i1=0,2
      i2=i+i1
      dvol1=dvol*ax1(i1)
      ap(2)=ap(2)+dvol1*ef(i2,j2,k2,2)
      ap(8)=ap(8)+dvol1*av(i2,j2,k2,3)
     end do
     do i1=0,1
      i2=i1+ih
      ap(6)=ap(6)+axh(i1)*dvol*ef(i2,j2,k2,6)   !Bz(i+1/2,j+1/2,k)
     end do
    end do
   end do
   !=========================
   do k1=0,1
    k2=kh+k1
    do j1=0,1
     j2=jh+j1
     dvol=ayh(j1)*azh(k1)
     do i1=0,2
      i2=i1+i
      ap(4)=ap(4)+ax1(i1)*dvol*ef(i2,j2,k2,4) !Bx(i,j+1/2,k+1/2)
     end do
    end do
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*azh(k1)
     do i1=0,1
      i2=ih+i1
      ap(5)=ap(5)+axh(i1)*dvol*ef(i2,j2,k2,5)  !By(i+1/2,j,k+1/2)
     end do
     do i1=0,2
      i2=i1+i
      dvol1=dvol*ax1(i1)
      ap(3)=ap(3)+dvol1*ef(i2,j2,k2,3)      !Ez(i,j,k=1/2)
      ap(9)=ap(9)+dvol1*av(i2,j2,k2,4)
     end do
    end do
   end do
   !=================================
   gam2=1.+up(1)*up(1)+up(2)*up(2)+up(3)*up(3)+ap(10)   !gamma^{n-1/2}
   !==================== solves a cubic equation gam^3=Agam+B
   a1=-dot_product(ap(1:3),up(1:3))
   b1=-dot_product(ap(7:9),up(1:3))
   gam=sqrt(gam2)
   gamp_new=gam+dth*(gam*a1+b1)/gam2
   ap(4:9)=ap(4:9)/gamp_new

   pt(1,n)=ap(1)+0.5*ap(7)
   pt(2,n)=ap(2)+0.5*ap(8)
   pt(3,n)=ap(3)+0.5*ap(9)        !E+F_{env}
   pt(1:6,n)=charge(2)*pt(1:6,n)  !F_Lorentz*q
   pt(7,n)=charge(1)*charge(2)/gamp_new     !weight*q/gamp
  end do
 end select
 end subroutine set_env_acc
 !-------------------------
 subroutine set_env_rk_acc(ef,av,sp_loc,pt,np,ndm,xmn,ymn,zmn)

 real(dp),intent(in) :: ef(:,:,:,:)
 real(dp),intent(inout) :: av(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,ndm
 real(dp),intent(in) :: xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol,dvol1,gam_inv,gam2,wgh
 real(dp) :: axh(0:2),ayh(0:2),up(3),xp1(3)
 real(dp) :: ax1(0:2),ay1(0:2),azh(0:2),az1(0:2),ap(12)
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n
 !===============================================
 real(sp) :: charge(2)
 equivalence(charge,wgh)
 !=============================================================
 ! particle indexing : i=1,....,nx => weights 1,.....nx+2
 ! Fields data[1:n1+2,1:n2+2,1:n3+2] ax(0)=> data(i), ax(1)=> data(i+1)
 ! ax(2)=>data(i+2)
 !===================================================
 ! enters av(1)=|a|^2/2 envelope at integer grid nodes
 ! exit ef(1:6) total Lorentz force and velocities
 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0;azh(0:2)=0.0
 axh(0:2)=0.0;ayh(0:2)=0.0

 k2=1
 select case(ndm)
 case(2)

  do n=1,np
   ap=0.0
   xp1(1:2)=sp_loc%part(n)%cmp(1:2)    !the current particle positions
   up(1:2)=sp_loc%part(n)%cmp(3:4)    !the current particle  momenta
   wgh=sp_loc%part(n)%cmp(5)          !the current particle  weight
   xx=shx+dx_inv*(xp1(1)-xmn)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)

   !axh(1)=sx+0.5
   !axh(0)=1.-axh(1)

   xx=shy+dy_inv*(xp1(2)-ymn)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   jh=int(xx)
   sx=xx-0.5-real(jh,dp)
   sx2=sx*sx
   ayh(1)=0.75-sx2
   ayh(2)=0.5*(0.25+sx2+sx)
   ayh(0)=1.-ayh(1)-ayh(2)

   !ayh(1)=sx+0.5
   !ayh(0)=1.-ayh(1)

   i=i-1
   j=j-1

   ih=ih-1
   jh=jh-1
   !==========================
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)
    do i1=0,2
     i2=i1+ih
     dvol1=dvol*axh(i1)
     ap(1)=ap(1)+dvol1*ef(i2,j2,k2,1)
     ap(4)=ap(4)+dvol1*av(i2,j2,k2,2)
    end do
    do i1=0,2
     i2=i1+i
     ap(6)=ap(6)+ax1(i1)*dvol*av(i2,j2,k2,1)!the p-assigned |A|^2/2 env field
    end do
   end do
   do j1=0,2
    j2=jh+j1
    dvol=ayh(j1)
    do i1=0,2
     i2=i+i1
     dvol1=dvol*ax1(i1)
     ap(2)=ap(2)+dvol1*ef(i2,j2,k2,2)
     ap(5)=ap(5)+dvol1*av(i2,j2,k2,3)
    end do
    do i1=0,2
     i2=i1+ih
     ap(3)=ap(3)+axh(i1)*dvol*ef(i2,j2,k2,3)
    end do
   end do
   !=========================
   gam2=1.+up(1)*up(1)+up(2)*up(2)+ap(6)
   gam_inv=1./sqrt(gam2)
   ap(4)=ap(4)*gam_inv
   ap(5)=ap(5)*gam_inv
   up(1:2)=up(1:2)*gam_inv
   pt(1,n)=ap(1)+0.5*ap(4)+up(2)*ap(3)      !Ex+F_x+v_yB_z
   pt(2,n)=ap(2)+0.5*ap(5)-up(1)*ap(3)      !Ey+F_y-v_x*B_z
   wgh=charge(2)
   pt(3:4,n)=wgh*up(1:2)
   pt(5,n)=wgh*gam_inv
  end do
  !========================
 case(3)
  do n=1,np
   ap=0.0
   xp1(1:3)=sp_loc%part(n)%cmp(1:3)   !the current particle positions
   up(1:3)=sp_loc%part(n)%cmp(4:6)    !the current particle  momenta
   wgh=sp_loc%part(n)%cmp(7)          !the current particle  wight
   xx=shx+dx_inv*(xp1(1)-xmn)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)

   !axh(1)=sx+0.5
   !axh(0)=1.-axh(1)

   xx=shy+dy_inv*(xp1(2)-ymn)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   jh=int(xx)
   sx=xx-0.5-real(jh,dp)
   sx2=sx*sx
   ayh(1)=0.75-sx2
   ayh(2)=0.5*(0.25+sx2+sx)
   ayh(0)=1.-ayh(1)-ayh(2)

   !ayh(1)=sx+0.5
   !ayh(0)=1.-ayh(1)

   xx=shz+dz_inv*(xp1(3)-zmn)
   k=int(xx+0.5)
   sx=xx-real(k,dp)
   sx2=sx*sx
   az1(1)=0.75-sx2
   az1(2)=0.5*(0.25+sx2+sx)
   az1(0)=1.-az1(1)-az1(2)

   kh=int(xx)
   sx=xx-0.5-real(kh,dp)
   sx2=sx*sx
   azh(1)=0.75-sx2
   azh(2)=0.5*(0.25+sx2+sx)
   azh(0)=1.-azh(1)-azh(2)

   !azh(1)=sx+0.5
   !azh(0)=1.-azh(1)

   i=i-1
   j=j-1
   k=k-1

   ih=ih-1
   jh=jh-1
   kh=kh-1
   !==========================
   do k1=0,2
    k2=k+k1
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*az1(k1)
     do i1=0,2
      i2=i1+ih
      dvol1=dvol*axh(i1)
      ap(1)=ap(1)+dvol1*ef(i2,j2,k2,1)
      ap(7)=ap(7)+dvol1*av(i2,j2,k2,2)   !D_x|A|^2/4
      i2=i1+i
      ap(10)=ap(10)+ax1(i1)*dvol*av(i2,j2,k2,1)! p-assigned |A|^2/2 field
     end do
    end do
    do j1=0,2
     j2=jh+j1
     dvol=ayh(j1)*az1(k1)
     do i1=0,2
      i2=i+i1
      dvol1=dvol*ax1(i1)
      ap(2)=ap(2)+dvol1*ef(i2,j2,k2,2)
      ap(8)=ap(8)+dvol1*av(i2,j2,k2,3)    !D_y|A|^2/4
      i2=i1+ih
      ap(6)=ap(6)+axh(i1)*dvol*ef(i2,j2,k2,6)
     end do
    end do
   end do
   !=========================
   do k1=0,2
    k2=kh+k1
    do j1=0,2
     j2=jh+j1
     dvol=ayh(j1)*azh(k1)
     do i1=0,2
      i2=i1+i
      ap(4)=ap(4)+ax1(i1)*dvol*ef(i2,j2,k2,4)
     end do
    end do
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*azh(k1)
     do i1=0,2
      i2=ih+i1
      ap(5)=ap(5)+axh(i1)*dvol*ef(i2,j2,k2,5)
      i2=i1+i
      dvol1=dvol*ax1(i1)
      ap(3)=ap(3)+dvol1*ef(i2,j2,k2,3)
      ap(9)=ap(9)+dvol1*av(i2,j2,k2,4)   !DZ|A|^2/4
     end do
    end do
   end do
   !=================================
   gam2=1.+up(1)*up(1)+up(2)*up(2)+up(3)*up(3)+ap(10)   !gamma^{i}
   gam_inv=1./sqrt(gam2)
   ap(7)=ap(7)*gam_inv
   ap(8)=ap(8)*gam_inv
   ap(9)=ap(9)*gam_inv
   up(1:3)=up(1:3)*gam_inv        !the velocity P/gam_p

   pt(1,n)=ap(1)+0.5*ap(7)    !E_x+F_x     F_i=0.5/gam_p*grad|A|^2/2
   pt(2,n)=ap(2)+0.5*ap(8)    !E_y+F_y
   pt(3,n)=ap(3)+0.5*ap(9)    !E_z+F_z
   pt(1,n)=pt(1,n)+up(2)*ap(6)-up(3)*ap(5)
   pt(2,n)=pt(2,n)+up(3)*ap(4)-up(1)*ap(6)
   pt(3,n)=pt(3,n)+up(1)*ap(5)-up(2)*ap(4)
   wgh=charge(2)
   pt(4:6,n)=wgh*up(1:3)
   pt(7,n)=wgh*gam_inv
  end do
 end select
 end subroutine set_env_rk_acc
 !=============================
 subroutine set_env_density(efp,av,np,ndm,xmn,ymn,zmn)

 real(dp),intent(in) :: efp(:,:)
 real(dp),intent(inout) :: av(:,:,:,:)
 integer,intent(in) :: np,ndm
 real(dp),intent(in) :: xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol,dvol1,wgh
 real(dp) :: xp1(3)
 real(dp) :: ax1(0:2),ay1(0:2),az1(0:2)
 integer :: i,j,i1,j1,i2,j2,k,k1,k2,n,ic
 !===============================================
 ! enter efp(1:4) positions and wgh*q/gamp at time level n
 ! exit av(:,:,:,ic) the envelope induced <q*n*wgh/gamp> density source
 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0

 ic=1
 select case(ndm)
 case(2)
  k2=1
  do n=1,np
   xp1(1)=dx_inv*(efp(1,n)-xmn)                ! local x
   xp1(2)=dy_inv*(efp(2,n)-ymn)                ! local y
   wgh=efp(5,n)                       !the current particle  q*wgh/gamp
   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   xx=shy+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   i=i-1
   j=j-1
   !==========================
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*wgh
    do i1=0,2
     i2=i1+i
     dvol1=dvol*ax1(i1)
     av(i2,j2,k2,ic)=av(i2,j2,k2,ic)+dvol1
    end do
   end do
  end do
  !========================
 case(3)
  do n=1,np
   xp1(1)=dx_inv*(efp(1,n)-xmn)                ! local x
   xp1(2)=dy_inv*(efp(2,n)-ymn)                ! local y
   xp1(3)=dz_inv*(efp(3,n)-zmn)                ! local z
   wgh=efp(7,n)          !the particle  q*w/gamp at t^n

   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   xx=shy+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   xx=shz+xp1(3)
   k=int(xx+0.5)
   sx=xx-real(k,dp)
   sx2=sx*sx
   az1(1)=0.75-sx2
   az1(2)=0.5*(0.25+sx2+sx)
   az1(0)=1.-az1(1)-az1(2)

   i=i-1
   j=j-1
   k=k-1
   !==========================
   do k1=0,2
    k2=k+k1
    do j1=0,2
     j2=j+j1
     dvol=ay1(j1)*az1(k1)*wgh
     do i1=0,2
      i2=i1+i
      dvol1=dvol*ax1(i1)
      av(i2,j2,k2,ic)=av(i2,j2,k2,ic)+dvol1
     end do
    end do
   end do
  end do
 end select
 end subroutine set_env_density
 !=============================

 subroutine set_part2d_twofield_acc(ef1,ef2,sp_loc,pt,np,sind,xmn,ymn)

 real(dp),intent(in) :: ef1(:,:,:,:),ef2(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np,sind
 real(dp),intent(in) :: xmn,ymn

 real(dp) :: wgh,xx,sx,sx2,dvol
 real(dp) :: axh(0:3),ayh(0:3),xp1(3)
 real(dp) :: ax1(0:3),ay1(0:3),ap(3)
 integer :: i,ih,j,jh,i1,j1,i2,j2,k2,n

 real(sp) :: charge(2)
 equivalence(charge,wgh)
 !===============================================
 ! Linear shape at half-index quadratic shape at integer index
 !====================================
 !=============================================================
 ! ef1 plasma wakefield
 ! ef2 bunch fields
 !====================
 ax1(0:3)=0.0;ay1(0:3)=0.0
 axh(0:3)=0.0;ayh(0:3)=0.0
 k2=1
 do n=1,np
  pt(1:2,n)=sp_loc%part(n)%cmp(1:2) ! the current part positions
  pt(1,n)=dx_inv*(pt(1,n)-xmn)
 end do
 if(sind==0)then
  do n=1,np
   xp1(2)=pt(2,n)
   pt(2,n)=dy_inv*(xp1(2)-ymn)
  end do
 else
  call map2dy_part_sind(np,sind,2,ymn,pt)
 endif
 do n=1,np
  ap(1:3)=0.0
  wgh=sp_loc%part(n)%cmp(5) ! the particle charge
  xp1(1:2)=pt(1:2,n)    !the current particle positions
  xx=shx+xp1(1)
  i=int(xx+0.5)
  sx=xx-real(i,dp)
  sx2=sx*sx
  ax1(1)=0.75-sx2
  ax1(2)=0.5*(0.25+sx2+sx)
  ax1(0)=1.-ax1(1)-ax1(2)

  axh(1)=sx+0.5
  axh(0)=1.-axh(1)

  xx=shy+xp1(2)
  j=int(xx+0.5)
  sx=xx-real(j,dp)
  sx2=sx*sx
  ay1(1)=0.75-sx2
  ay1(2)=0.5*(0.25+sx2+sx)
  ay1(0)=1.-ay1(1)-ay1(2)

  ayh(1)=sx+0.5
  ayh(0)=1.-ayh(1)

  i=i-1
  j=j-1

  ih=i
  jh=j
  ! Ex(i+1/2,j,k)
  !==============
  !==============
  ! Ey(i,j+1/2,k)
  !==============
  !==============
  ! Bz(i+1/2,j+1/2,k)
  !==============
  do j1=0,2
   j2=j+j1
   dvol=ay1(j1)
   do i1=0,1
    i2=i1+ih
    ap(1)=ap(1)+axh(i1)*dvol*(ef1(i2,j2,k2,1)+ef2(i2,j2,k2,1))
   end do
  end do
  do j1=0,1
   j2=jh+j1
   dvol=ayh(j1)
   do i1=0,2
    i2=i+i1
    ap(2)=ap(2)+ax1(i1)*dvol*(ef1(i2,j2,k2,2) +ef2(i2,j2,k2,2))
   end do
   do i1=0,1
    i2=i1+ih
    ap(3)=ap(3)+axh(i1)*dvol*(ef1(i2,j2,k2,3)+ef2(i2,j2,k2,3))
   end do
  end do
  wgh=charge(2)
  pt(1:3,n)=wgh*ap(1:3)
 end do
 !================================
 end subroutine set_part2d_twofield_acc

 subroutine set_part3d_two_bfield_acc(ef1,ef2,ef3,&
  sp_loc,pt,n0,np,sind,xmn,ymn,zmn)

 real(dp),intent(in) :: ef1(:,:,:,:),ef2(:,:,:,:),ef3(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: n0,np,sind
 real(dp),intent(in) :: xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol
 real(dp) :: axh(0:3),ayh(0:3),xp1(3)
 real(dp) :: ax1(0:3),ay1(0:3),azh(0:3),az1(0:3),ap(6),eftot
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n

 !===============================================
 ! Linear shape at half-index quadratic shape at integer index
 !====================================
 !=============================================================
 ! particle indexing : i=1,....,nx => weights 1,.....nx+2
 ! Fields data[1:n1+2,1:n2+2,1:n3+2] ax(0)=> data(i), ax(1)=> data(i+1) ax(3)=>data(i+2)
 !===================================================
 ! ef1 plasma wakefield
 ! ef2 bunch self-fields
 !====================
 do n=n0,np
  pt(1:3,n)=sp_loc%part(n)%cmp(1:3) ! the current part positions
  pt(1,n)=dx_inv*(pt(1,n)-xmn)
 end do
 if(sind==0)then
  do n=n0,np
   xp1(2:3)=pt(2:3,n)
   pt(2,n)=dy_inv*(xp1(2)-ymn)
   pt(3,n)=dz_inv*(xp1(3)-zmn)
  end do
 else
  call map3d_part_sind(pt,np,sind,2,3,ymn,zmn)
 endif
 do n=n0,np
  ap(1:6)=0.0
  xp1(1:3)=pt(1:3,n)    !the current particle positions
  xx=shx+xp1(1)
  i=int(xx+0.5)
  sx=xx-real(i,dp)
  sx2=sx*sx
  ax1(1)=0.75-sx2
  ax1(2)=0.5*(0.25+sx2+sx)
  ax1(0)=1.-ax1(1)-ax1(2)

  axh(1)=sx+0.5
  axh(0)=1.-axh(1)

  xx=shy+xp1(2)
  j=int(xx+0.5)
  sx=xx-real(j,dp)
  sx2=sx*sx
  ay1(1)=0.75-sx2
  ay1(2)=0.5*(0.25+sx2+sx)
  ay1(0)=1.-ay1(1)-ay1(2)

  ayh(1)=sx+0.5
  ayh(0)=1.-ayh(1)

  xx=shz+xp1(3)
  k=int(xx+0.5)
  sx=xx-real(k,dp)
  sx2=sx*sx
  az1(1)=0.75-sx2
  az1(2)=0.5*(0.25+sx2+sx)
  az1(0)=1.-az1(1)-az1(2)

  azh(1)=sx+0.5
  azh(0)=1.-azh(1)

  i=i-1
  j=j-1
  k=k-1

  ih=i
  jh=j
  kh=k
  ! Ex(i+1/2,j,k)
  !==============
  !==============
  ! Ey(i,j+1/2,k)
  !==============
  !==============
  ! Bz(i+1/2,j+1/2,k)
  !==============
  do k1=0,2
   k2=k+k1
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*az1(k1)
    do i1=0,1
     i2=i1+ih
     eftot=ef1(i2,j2,k2,1)+ef2(i2,j2,k2,1)+ef3(i2,j2,k2,1)
     ap(1)=ap(1)+axh(i1)*dvol*eftot
    end do
   end do
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)*az1(k1)
    do i1=0,2
     i2=i+i1
     eftot=ef1(i2,j2,k2,2)+ef2(i2,j2,k2,2)+ef3(i2,j2,k2,2)
     ap(2)=ap(2)+ax1(i1)*dvol*eftot
    end do
    do i1=0,1
     i2=i1+ih
     eftot=ef1(i2,j2,k2,6)+ef2(i2,j2,k2,6)+ef3(i2,j2,k2,6)
     ap(6)=ap(6)+axh(i1)*dvol*eftot
    end do
   end do
  end do
  !==============
  ! Bx(i,j+1/2,k+1/2)
  !==============
  !==============
  ! By(i+1/2,j,k+1/2)
  !==============
  !==============
  ! Ez(i,j,k+1/2)
  !==============

  do k1=0,1
   k2=kh+k1
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)*azh(k1)
    do i1=0,2
     eftot=ef1(i2,j2,k2,4)+ef3(i2,j2,k2,4)
     i2=i1+i
     ap(4)=ap(4)+ax1(i1)*dvol*eftot
    end do
   end do
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*azh(k1)
    do i1=0,1
     i2=ih+i1
     eftot=ef1(i2,j2,k2,5)+ef2(i2,j2,k2,5)+ef3(i2,j2,k2,5)
     ap(5)=ap(5)+axh(i1)*dvol*eftot
    end do
    do i1=0,2
     i2=i1+i
     eftot=ef1(i2,j2,k2,3)+ef2(i2,j2,k2,3)+ef3(i2,j2,k2,3)
     ap(3)=ap(3)+ax1(i1)*dvol*eftot
    end do
   end do
  end do
  pt(1:6,n)=ap(1:6)
 end do
 !================================
 end subroutine set_part3d_two_bfield_acc

 subroutine set_part3d_three_bfield_acc(ef1,ef2,ef3,ef4,sp_loc,pt,n0,np,sind,xmn,ymn,zmn)

 real(dp),intent(in) :: ef1(:,:,:,:),ef2(:,:,:,:),ef3(:,:,:,:),ef4(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: n0,np,sind
 real(dp),intent(in) :: xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol
 real(dp) :: axh(0:3),ayh(0:3),xp1(3)
 real(dp) :: ax1(0:3),ay1(0:3),azh(0:3),az1(0:3),ap(6),eftot
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n

 !===============================================
 ! Linear shape at half-index quadratic shape at integer index
 !====================================
 !=============================================================
 ! particle indexing : i=1,....,nx => weights 1,.....nx+2
 ! Fields data[1:n1+2,1:n2+2,1:n3+2] ax(0)=> data(i), ax(1)=> data(i+1) ax(3)=>data(i+2)
 !===================================================
 ! ef1 plasma wakefield
 ! ef2 bunch self-fields
 ! ef4 poloidal external field
 !====================
 do n=n0,np
  pt(1:3,n)=sp_loc%part(n)%cmp(1:3) ! the current part positions
  pt(1,n)=dx_inv*(pt(1,n)-xmn)
 end do
 if(sind==0)then
  do n=n0,np
   xp1(2:3)=pt(2:3,n)
   pt(2,n)=dy_inv*(xp1(2)-ymn)
   pt(3,n)=dz_inv*(xp1(3)-zmn)
  end do
 else
  call map3d_part_sind(pt,np,sind,2,3,ymn,zmn)
 endif
 do n=n0,np
  ap(1:6)=0.0
  xp1(1:3)=pt(1:3,n)    !the current particle positions
  xx=shx+xp1(1)
  i=int(xx+0.5)
  sx=xx-real(i,dp)
  sx2=sx*sx
  ax1(1)=0.75-sx2
  ax1(2)=0.5*(0.25+sx2+sx)
  ax1(0)=1.-ax1(1)-ax1(2)

  axh(1)=sx+0.5
  axh(0)=1.-axh(1)

  xx=shy+xp1(2)
  j=int(xx+0.5)
  sx=xx-real(j,dp)
  sx2=sx*sx
  ay1(1)=0.75-sx2
  ay1(2)=0.5*(0.25+sx2+sx)
  ay1(0)=1.-ay1(1)-ay1(2)

  ayh(1)=sx+0.5
  ayh(0)=1.-ayh(1)

  xx=shz+xp1(3)
  k=int(xx+0.5)
  sx=xx-real(k,dp)
  sx2=sx*sx
  az1(1)=0.75-sx2
  az1(2)=0.5*(0.25+sx2+sx)
  az1(0)=1.-az1(1)-az1(2)

  azh(1)=sx+0.5
  azh(0)=1.-azh(1)

  i=i-1
  j=j-1
  k=k-1

  ih=i
  jh=j
  kh=k
  ! Ex(i+1/2,j,k)
  !==============
  !==============
  ! Ey(i,j+1/2,k)
  !==============
  !==============
  ! Bz(i+1/2,j+1/2,k)
  !==============
  do k1=0,2
   k2=k+k1
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*az1(k1)
    do i1=0,1
     i2=i1+ih
     eftot=ef1(i2,j2,k2,1)+ef2(i2,j2,k2,1)+ef3(i2,j2,k2,1)!+ef4(i2,j2,k2,---)
     ap(1)=ap(1)+axh(i1)*dvol*eftot
    end do
   end do
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)*az1(k1)
    do i1=0,2
     i2=i+i1
     eftot=ef1(i2,j2,k2,2)+ef2(i2,j2,k2,2)+ef3(i2,j2,k2,2)!+ef4(i2,j2,k2,---)
     ap(2)=ap(2)+ax1(i1)*dvol*eftot
    end do
    do i1=0,1
     i2=i1+ih
     eftot=ef1(i2,j2,k2,6)+ef2(i2,j2,k2,6)+ef3(i2,j2,k2,6)+ef4(i2,j2,k2,3)
     ap(6)=ap(6)+axh(i1)*dvol*eftot
    end do
   end do
  end do
  !==============
  ! Bx(i,j+1/2,k+1/2)
  !==============
  !==============
  ! By(i+1/2,j,k+1/2)
  !==============
  !==============
  ! Ez(i,j,k+1/2)
  !==============

  do k1=0,1
   k2=kh+k1
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)*azh(k1)
    do i1=0,2
     eftot=ef1(i2,j2,k2,4)+ef3(i2,j2,k2,4)+ef4(i2,j2,k2,1)
     i2=i1+i
     ap(4)=ap(4)+ax1(i1)*dvol*eftot
    end do
   end do
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*azh(k1)
    do i1=0,1
     i2=ih+i1
     eftot=ef1(i2,j2,k2,5)+ef2(i2,j2,k2,5)+ef3(i2,j2,k2,5)+ef4(i2,j2,k2,2)
     ap(5)=ap(5)+axh(i1)*dvol*eftot
    end do
    do i1=0,2
     i2=i1+i
     eftot=ef1(i2,j2,k2,3)+ef2(i2,j2,k2,3)+ef3(i2,j2,k2,3)!+ef4(i2,j2,k2,---)
     ap(3)=ap(3)+ax1(i1)*dvol*eftot
    end do
   end do
  end do
  pt(1:6,n)=ap(1:6)
 end do
 !================================
 end subroutine set_part3d_three_bfield_acc


 subroutine set_part3d_twofield_acc(ef1,ef2,sp_loc,pt,n0,np,sind,xmn,ymn,zmn)

 real(dp),intent(in) :: ef1(:,:,:,:),ef2(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: n0,np,sind
 real(dp),intent(in) :: xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol
 real(dp) :: axh(0:3),ayh(0:3),xp1(3)
 real(dp) :: ax1(0:3),ay1(0:3),azh(0:3),az1(0:3),ap(6)
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n

 !===============================================
 ! Linear shape at half-index quadratic shape at integer index
 !====================================
 !=============================================================
 ! particle indexing : i=1,....,nx => weights 1,.....nx+2
 ! Fields data[1:n1+2,1:n2+2,1:n3+2] ax(0)=> data(i), ax(1)=> data(i+1) ax(3)=>data(i+2)
 !===================================================
 ! ef1 plasma wakefield
 ! ef2 bunch self-fields
 !====================
 do n=n0,np
  pt(1:3,n)=sp_loc%part(n)%cmp(1:3) ! the current part positions
  pt(1,n)=dx_inv*(pt(1,n)-xmn)
 end do
 if(sind==0)then
  do n=n0,np
   xp1(2:3)=pt(2:3,n)
   pt(2,n)=dy_inv*(xp1(2)-ymn)
   pt(3,n)=dz_inv*(xp1(3)-zmn)
  end do
 else
  call map3d_part_sind(pt,np,sind,2,3,ymn,zmn)
 endif
 do n=n0,np
  ap(1:6)=0.0
  xp1(1:3)=pt(1:3,n)    !the current particle positions
  xx=shx+xp1(1)
  i=int(xx+0.5)
  sx=xx-real(i,dp)
  sx2=sx*sx
  ax1(1)=0.75-sx2
  ax1(2)=0.5*(0.25+sx2+sx)
  ax1(0)=1.-ax1(1)-ax1(2)

  axh(1)=sx+0.5
  axh(0)=1.-axh(1)

  xx=shy+xp1(2)
  j=int(xx+0.5)
  sx=xx-real(j,dp)
  sx2=sx*sx
  ay1(1)=0.75-sx2
  ay1(2)=0.5*(0.25+sx2+sx)
  ay1(0)=1.-ay1(1)-ay1(2)

  ayh(1)=sx+0.5
  ayh(0)=1.-ayh(1)

  xx=shz+xp1(3)
  k=int(xx+0.5)
  sx=xx-real(k,dp)
  sx2=sx*sx
  az1(1)=0.75-sx2
  az1(2)=0.5*(0.25+sx2+sx)
  az1(0)=1.-az1(1)-az1(2)

  azh(1)=sx+0.5
  azh(0)=1.-azh(1)

  i=i-1
  j=j-1
  k=k-1

  ih=i
  jh=j
  kh=k
  ! Ex(i+1/2,j,k)
  !==============
  !==============
  ! Ey(i,j+1/2,k)
  !==============
  !==============
  ! Bz(i+1/2,j+1/2,k)
  !==============
  do k1=0,2
   k2=k+k1
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*az1(k1)
    do i1=0,1
     i2=i1+ih
     ap(1)=ap(1)+axh(i1)*dvol*(ef1(i2,j2,k2,1)+ef2(i2,j2,k2,1))
    end do
   end do
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)*az1(k1)
    do i1=0,2
     i2=i+i1
     ap(2)=ap(2)+ax1(i1)*dvol*(ef1(i2,j2,k2,2) +ef2(i2,j2,k2,2))
    end do
    do i1=0,1
     i2=i1+ih
     ap(6)=ap(6)+axh(i1)*dvol*(ef1(i2,j2,k2,6)+ef2(i2,j2,k2,6))
    end do
   end do
  end do
  !==============
  ! Bx(i,j+1/2,k+1/2)
  !==============
  !==============
  ! By(i+1/2,j,k+1/2)
  !==============
  !==============
  ! Ez(i,j,k+1/2)
  !==============

  do k1=0,1
   k2=kh+k1
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)*azh(k1)
    do i1=0,2
     i2=i1+i
     ap(4)=ap(4)+ax1(i1)*dvol*ef1(i2,j2,k2,4)
    end do
   end do
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*azh(k1)
    do i1=0,1
     i2=ih+i1
     ap(5)=ap(5)+axh(i1)*dvol*(ef1(i2,j2,k2,5) +ef2(i2,j2,k2,5))
    end do
    do i1=0,2
     i2=i1+i
     ap(3)=ap(3)+ax1(i1)*dvol*(ef1(i2,j2,k2,3)+ef2(i2,j2,k2,3))
    end do
   end do
  end do
  pt(1:6,n)=ap(1:6)
 end do
 !================================
 end subroutine set_part3d_twofield_acc
 !==================================
 subroutine set_part3d_threefield_acc(&
  ef1,ef2,ef3,sp_loc,pt,np1,np,xmn,ymn,zmn)

 real(dp),intent(in) :: ef1(:,:,:,:),ef2(:,:,:,:), ef3(:,:,:,:)
 type(species),intent(in) :: sp_loc
 real(dp),intent(out) :: pt(:,:)
 integer,intent(in) :: np1,np
 real(dp),intent(in) :: xmn,ymn,zmn

 real(dp) :: xx,sx,sx2,dvol
 real(dp) :: axh(0:3),ayh(0:3),xp1(3)
 real(dp) :: ax1(0:3),ay1(0:3),azh(0:3),az1(0:3),ap(6)
 integer :: i,ih,j,jh,i1,j1,i2,j2,k,kh,k1,k2,n

 !===============================================
 ! Linear shape at half-index quadratic shape at integer index
 !====================================
 !=============================================================
 ! particle indexing : i=1,....,nx => weights 1,.....nx+2
 ! Fields data[1:n1+2,1:n2+2,1:n3+2] ax(0)=> data(i), ax(1)=> data(i+1) ax(3)=>data(i+2)
 !===================================================
 ! ef1 plasma wakefield
 ! ef2 bunch self-fields
 !====================
 do n=np1,np
  pt(1:3,n)=sp_loc%part(n)%cmp(1:3) ! the current part positions
  pt(1,n)=dx_inv*(pt(1,n)-xmn)
  pt(2,n)=dy_inv*(pt(2,n)-ymn)
  pt(3,n)=dz_inv*(pt(3,n)-zmn)

  ap(1:6)=0.0
  xp1(1:3)=pt(1:3,n)    !the current particle positions
  xx=shx+xp1(1)
  i=int(xx+0.5)
  sx=xx-real(i,dp)
  sx2=sx*sx
  ax1(1)=0.75-sx2
  ax1(2)=0.5*(0.25+sx2+sx)
  ax1(0)=1.-ax1(1)-ax1(2)

  axh(1)=sx+0.5
  axh(0)=1.-axh(1)

  xx=shy+xp1(2)
  j=int(xx+0.5)
  sx=xx-real(j,dp)
  sx2=sx*sx
  ay1(1)=0.75-sx2
  ay1(2)=0.5*(0.25+sx2+sx)
  ay1(0)=1.-ay1(1)-ay1(2)

  ayh(1)=sx+0.5
  ayh(0)=1.-ayh(1)

  xx=shz+xp1(3)
  k=int(xx+0.5)
  sx=xx-real(k,dp)
  sx2=sx*sx
  az1(1)=0.75-sx2
  az1(2)=0.5*(0.25+sx2+sx)
  az1(0)=1.-az1(1)-az1(2)

  azh(1)=sx+0.5
  azh(0)=1.-azh(1)

  i=i-1
  j=j-1
  k=k-1

  ih=i
  jh=j
  kh=k
  ! Ex(i+1/2,j,k)
  !==============
  !==============
  ! Ey(i,j+1/2,k)
  !==============
  !==============
  ! Bz(i+1/2,j+1/2,k)
  !==============
  do k1=0,2
   k2=k+k1
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*az1(k1)
    do i1=0,1
     i2=i1+ih
     ap(1)=ap(1)+axh(i1)*dvol*(ef1(i2,j2,k2,1)+ef2(i2,j2,k2,1))
    end do
   end do
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)*az1(k1)
    do i1=0,2
     i2=i+i1
     ap(2)=ap(2)+ax1(i1)*dvol*(ef1(i2,j2,k2,2) +ef2(i2,j2,k2,2))
    end do
    do i1=0,1
     i2=i1+ih
     ap(6)=ap(6)+axh(i1)*dvol*(&
      ef1(i2,j2,k2,6)+ef2(i2,j2,k2,6)+ef3(i2,j2,k2,3))
    end do
   end do
  end do
  !==============
  ! Bx(i,j+1/2,k+1/2)
  !==============
  !==============
  ! By(i+1/2,j,k+1/2)
  !==============
  !==============
  ! Ez(i,j,k+1/2)
  !==============

  do k1=0,1
   k2=kh+k1
   do j1=0,1
    j2=jh+j1
    dvol=ayh(j1)*azh(k1)
    do i1=0,2
     i2=i1+i
     ap(4)=ap(4)+ax1(i1)*dvol*(ef1(i2,j2,k2,4)+ef3(i2,j2,k2,1))
    end do
   end do
   do j1=0,2
    j2=j+j1
    dvol=ay1(j1)*azh(k1)
    do i1=0,1
     i2=ih+i1
     ap(5)=ap(5)+axh(i1)*dvol*(&
      ef1(i2,j2,k2,5) +ef2(i2,j2,k2,5)+ef3(i2,j2,k2,2))
    end do
    do i1=0,2
     i2=i1+i
     ap(3)=ap(3)+ax1(i1)*dvol*(ef1(i2,j2,k2,3)+ef2(i2,j2,k2,3))
    end do
   end do
  end do
  pt(1:6,n)=ap(1:6)
 end do
 !================================
 end subroutine set_part3d_threefield_acc
 !==================================
 !========= END OF SECTION for ACCELERATION FIELDS ASSIGNEMENT
 !==========================================
 !====================================================
 !========= PARTICLE ASSIGNEMENT TO GRID FOR CURRENT DENSITY
 !=============================
 subroutine esirkepov_2d_curr(sp_loc,part,n0,np,n_st,njc,ndm,xmn,ymn)

 type(species),intent(in) :: sp_loc
 real(dp),intent(inout) :: part(:,:)
 integer,intent(in) :: n0,np,n_st,njc,ndm
 real(dp),intent(in) :: xmn,ymn
 real(dp) :: ax,sx,sx2,dvol,wgh
 real(dp) :: ax0(0:3),ay0(0:3),xp1(3),xp0(3)
 real(dp) :: ax1(0:3),ay1(0:3),vp(3),vyp
 real(dp) :: axh(0:4),axh0(0:4),axh1(0:4),ayh(0:4)
 real(dp) :: currx(0:4),curry(0:4)
 integer :: i,j,i0,j0,i1,j1,i2,j2,n
 integer :: ih,jh,ix0,ix1,iy0,iy1
 !=======================
 real(sp) :: charge(2)
 equivalence(charge,wgh)
 !==========================
 !Iform==1 IMPLEMENTS the ESIRKEPOV SCHEME for QUADRATIC SHAPE
 ! The Jx current density component is obtained later by
 ! inversion of the D_x[J_x]=D_t[rho] finite difference equation
 ! on the x-grid
 !==========================================
 ax1=0.0
 ay1=0.0
 ax0=0.0
 ay0=0.0
 select case(ndm)
 case(1)
  do n=n0,np
   xp1(1:2)=sp_loc%part(n)%cmp(1:2) !x-new  t^(n+1)
   xp0(1:2)=part(3:4,n)             !x-old  t^n
   vp(1:2)=xp1(1:2)-xp0(1:2)
   wgh=sp_loc%part(n)%cmp(5)
   wgh=charge(1)*charge(2)
   vyp=0.5*wgh*vp(2)                !q*Dt*Vy time level t^(n+1/2)

   ax=shx+dx_inv*(xp0(1)-xmn)
   i0=int(ax+0.5)
   sx=ax-real(i0,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)

   ax=shx+dx_inv*(xp1(1)-xmn)
   i=int(ax+0.5)
   sx=ax-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   axh(0:4)=0.0
   !-----------------------
   ih=i-i0+1
   do i1=0,2
    axh(ih+i1)=ax1(i1)
   end do
   i=i-1
   i0=i0-1

   currx(0)=-axh(0)
   do i1=1,3
    currx(i1)=currx(i1-1)+ax0(i1-1)-axh(i1)
   end do
   currx(4)=currx(3)-axh(4)
   currx(0:4)=wgh*currx(0:4)
   ih=i0-1
   do i1=0,4
    i2=ih+i1
    jc(i2,1,1,1)=jc(i2,1,1,1)+currx(i1)
   end do
   !++++++++++++++
   ! jc(1)=[rho_old-rho_new]=dt*Der_xJ_x
   ! Jx has to be computed by inversion on the x-grid
   !=============================
   do i1=0,2
    i2=i0+i1-1
    jc(i2,1,1,2)=jc(i2,1,1,2)+vyp*ax0(i1)
    i2=i+i1-1
    jc(i2,1,1,2)=jc(i2,1,1,2)+vyp*ax1(i1)
   end do
  end do
  !======================
 case(2)
  if(njc==2)then
   do n=1,np
    part(2,n)=sp_loc%part(n)%cmp(2) !y-new  t^(n+1)
    xp1(1)=sp_loc%part(n)%cmp(1)    !x-new  t^(n+1)
    xp0(1)=part(3,n)                !x-old
    part(1,n)=dx_inv*(xp1(1)-xmn)
    part(3,n)=dx_inv*(xp0(1)-xmn)
   end do
   if(n_st==0)then
    do n=n0,np
     xp1(2)=part(2,n)                !y-new
     xp0(2)=part(4,n)                !y-old
     part(2,n)=dy_inv*(xp1(2)-ymn)
     part(4,n)=dy_inv*(xp0(2)-ymn)
    end do
   else
    call map2dy_part_sind(np,n_st,2,ymn,part)
    call map2dy_part_sind(np,n_st,4,ymn,part)
   endif
   do n=n0,np
    xp1(1:2)=part(1:2,n)                !x-new
    xp0(1:2)=part(3:4,n)                !x-old
    wgh=sp_loc%part(n)%cmp(5)
    wgh=charge(1)*charge(2)
    !=====================
    ax=shx+xp0(1)
    i0=int(ax+0.5)
    sx=ax-real(i0,dp)
    sx2=sx*sx
    ax0(1)=0.75-sx2
    ax0(2)=0.5*(0.25+sx2+sx)
    ax0(0)=1.-ax0(1)-ax0(2)

    ax=shx+xp1(1)
    i=int(ax+0.5)
    sx=ax-real(i,dp)
    sx2=sx*sx
    ax1(1)=0.75-sx2
    ax1(2)=0.5*(0.25+sx2+sx)
    ax1(0)=1.-ax1(1)-ax1(2)
    axh(0:4)=0.0
    ih=i-i0+1
    do i1=0,2
     axh(ih+i1)=ax1(i1)
    end do
    currx(0)=-axh(0)
    do i1=1,3
     currx(i1)=currx(i1-1)+ax0(i1-1)-axh(i1)
    end do
    currx(4)=currx(3)-axh(4)
    do i1=1,3
     axh(i1)=axh(i1)+ax0(i1-1)
    end do
    currx(0:4)=wgh*currx(0:4)
    ix0=min(ih,1)
    ix1=max(ih+2,3)
    !-------
    ax=shy+xp0(2)
    j0=int(ax+0.5)
    sx=ax-real(j0,dp)
    sx2=sx*sx
    ay0(1)=0.75-sx2
    ay0(2)=0.5*(0.25+sx2+sx)
    ay0(0)=1.-ay0(1)-ay0(2)

    ax=shy+xp1(2)
    j=int(ax+0.5)
    sx=ax-real(j,dp)
    sx2=sx*sx
    ay1(1)=0.75-sx2
    ay1(2)=0.5*(0.25+sx2+sx)
    ay1(0)=1.-ay1(1)-ay1(2)

    jh=j-j0+1
    ayh(0:4)=0.0
    do i1=0,2
     ayh(jh+i1)=ay1(i1)
    end do
    curry(0)=-ayh(0)
    do i1=1,3
     curry(i1)=curry(i1-1)+ay0(i1-1)-ayh(i1)
    end do
    curry(4)=curry(3)-ayh(4)
    curry(0:4)=wgh*curry(0:4)
    !========================================
    do i1=1,3
     ayh(i1)=ayh(i1)+ay0(i1-1)
    end do
    iy0=min(jh,1)
    iy1=max(jh+2,3)
    !================dt*J_x
    j0=j0-1
    j=j-1
    jh=j0-1

    i=i-1
    i0=i0-1
    ih=i0-1

    do j1=iy0,iy1
     j2=jh+j1
     do i1=ix0,ix1
      i2=ih+i1
      jc(i2,j2,1,1)=jc(i2,j2,1,1)+ayh(j1)*currx(i1)
     end do
    end do
    !================dt*J_y
    do j1=iy0,iy1
     j2=jh+j1
     do i1=ix0,ix1
      i2=ih+i1
      jc(i2,j2,1,2)=jc(i2,j2,1,2)+axh(i1)*curry(j1)
     end do
    end do
   end do
  endif
  if(njc==3)then
   do n=n0,np
    part(2:3,n)=sp_loc%part(n)%cmp(2:3) !yz-new  t^(n+1)
    xp1(1)=sp_loc%part(n)%cmp(1)    !x-new
    xp0(1)=part(4,n)                !x-old
    part(1,n)=dx_inv*(xp1(1)-xmn)
    part(4,n)=dx_inv*(xp0(1)-xmn)
   end do
   if(n_st==0)then
    do n=n0,np
     xp1(2)=part(2,n)                !y-new
     xp0(2)=part(5,n)                !y-old
     part(2,n)=dy_inv*(xp1(2)-ymn)
     part(5,n)=dy_inv*(xp0(2)-ymn)
    end do
   else
    call map2dy_part_sind(np,n_st,2,ymn,part)
    call map2dy_part_sind(np,n_st,5,ymn,part)
   endif
   do n=n0,np
    xp1(1:3)=part(1:3,n)                !increments xy-new
    xp0(1:3)=part(4:6,n)                !increments xy and z-old
    wgh=sp_loc%part(n)%cmp(7)
    wgh=charge(1)*charge(2)
    vp(3)=xp1(3)-xp0(3)                    !dt*v_z(n+1/2)
    vp(3)=wgh*vp(3)/3.                     !dt*vz/3
    !=====================
    ax=shx+xp0(1)
    i0=int(ax+0.5)
    sx=ax-real(i0,dp)
    sx2=sx*sx
    ax0(1)=0.75-sx2
    ax0(2)=0.5*(0.25+sx2+sx)
    ax0(0)=1.-ax0(1)-ax0(2)

    ax=shx+xp1(1)
    i=int(ax+0.5)
    sx=ax-real(i,dp)
    sx2=sx*sx
    ax1(1)=0.75-sx2
    ax1(2)=0.5*(0.25+sx2+sx)
    ax1(0)=1.-ax1(1)-ax1(2)
    axh(0:4)=0.0
    ih=i-i0+1
    ix0=min(ih,1)
    ix1=max(ih+2,3)
    do i1=0,2
     axh(ih+i1)=ax1(i1)
    end do
    currx(0)=-axh(0)
    do i1=1,3
     currx(i1)=currx(i1-1)+ax0(i1-1)-axh(i1)
    end do
    currx(4)=currx(3)-axh(4)
    do i1=1,3
     axh(i1)=axh(i1)+ax0(i1-1)
    end do
    currx(0:4)=wgh*currx(0:4)

    axh0(0:4)=0.5*axh(0:4)
    axh1(0:4)=axh(0:4)
    do i1=1,3
     axh0(i1)=axh0(i1)+ax0(i1-1)
     axh1(i1)=axh1(i1)+0.5*ax0(i1-1)
     axh(i1)=axh(i1)+ax0(i1-1)         !Wx^0+Wx^1)
    end do
    !-------
    i=i-1
    i0=i0-1

    ax=shy+xp0(2)
    j0=int(ax+0.5)
    sx=ax-real(j0,dp)
    sx2=sx*sx
    ay0(1)=0.75-sx2
    ay0(2)=0.5*(0.25+sx2+sx)
    ay0(0)=1.-ay0(1)-ay0(2)

    ax=shy+xp1(2)
    j=int(ax+0.5)
    sx=ax-real(j,dp)
    sx2=sx*sx
    ay1(1)=0.75-sx2
    ay1(2)=0.5*(0.25+sx2+sx)
    ay1(0)=1.-ay1(1)-ay1(2)

    jh=j-j0+1
    iy0=min(jh,1)
    iy1=max(jh+2,3)

    ayh(0:4)=0.0
    do i1=0,2
     ayh(jh+i1)=ay1(i1)
    end do
    curry(0)=-ayh(0)
    do i1=1,3
     curry(i1)=curry(i1-1)+ay0(i1-1)-ayh(i1)
    end do
    curry(4)=curry(3)-ayh(4)
    curry(0:4)=wgh*curry(0:4)
    do i1=1,3
     ayh(i1)=ayh(i1)+ay0(i1-1)
    end do
    !-----------
    j0=j0-1
    j=j-1
    !================dt*J_x= currx*(Wy^0+Wy^1) to be multiplied by dx/2
    ih=i0-1
    jh=j0-1
    do j1=iy0,iy1
     j2=jh+j1
     do i1=ix0,ix1
      i2=ih+i1
      jc(i2,j2,1,1)=jc(i2,j2,1,1)+ayh(j1)*currx(i1)
     end do
    end do
    !================dt*J_y= curry*(Wx^0+Wx^1)
    do j1=iy0,iy1
     j2=jh+j1
     do i1=ix0,ix1
      i2=ih+i1
      jc(i2,j2,1,2)=jc(i2,j2,1,2)+axh(i1)*curry(j1)
     end do
    end do
    !========== dt*J_z Vz*[Wy^0(Wx^0+0.5*Wx^1)+Wy^1*(Wx^1+0.5*Wx^0)]
    do j1=0,2
     j2=j0+j1
     dvol=ay0(j1)*vp(3)
     do i1=ix0,ix1
      i2=i1+ih
      jc(i2,j2,1,3)=jc(i2,j2,1,3)+axh0(i1)*dvol
     end do
     j2=j+j1
     dvol=ay1(j1)*vp(3)
     do i1=ix0,ix1
      i2=i1+ih
      jc(i2,j2,1,3)=jc(i2,j2,1,3)+axh1(i1)*dvol
     end do
    end do
   end do
  endif
 end select
 !-----------------------
 end subroutine esirkepov_2d_curr
 !==========================================
 subroutine pdef_2d_curr(sp_loc,part,n0,np,n_st,njc,ndm,xmn,ymn)

 type(species),intent(in) :: sp_loc
 real(dp),intent(inout) :: part(:,:)
 integer,intent(in) :: n0,np,n_st,njc,ndm
 real(dp),intent(in) :: xmn,ymn
 real(dp) :: ax,sx,sx2,dvol,wgh
 real(dp) :: ax0(0:3),ay0(0:3),xp1(3),xp0(3)
 real(dp) :: ax1(0:3),ay1(0:3),vp(3),vyp
 real(dp) :: axh(0:4),axh0(0:4),axh1(0:4),ayh(0:4)
 real(dp) :: dcurrx(0:4),curry(0:4)
 integer :: i,j,i0,j0,i1,j1,i2,j2,n
 integer :: ih,jh,ix0,ix1,iy0,iy1
 !=======================
 real(sp) :: charge(2)
 equivalence(charge,wgh)
 !==========================
 !Iform==1 IMPLEMENTS the ESIRKEPOV SCHEME for QUADRATIC SHAPE
 ! The Jx current density component is obtained later by
 ! inversion of the D_x[J_x]=D_t[rho] finite difference equation
 ! on the x-grid
 !==========================================
 ax1=0.0
 ay1=0.0
 ax0=0.0
 ay0=0.0
 select case(ndm)
 case(1)
  do n=n0,np
   xp1(1:2)=sp_loc%part(n)%cmp(1:2) !x-new  t^(n+1)
   xp0(1:2)=part(3:4,n)             !x-old  t^n
   vp(1:2)=xp1(1:2)-xp0(1:2)
   wgh=sp_loc%part(n)%cmp(5)
   wgh=charge(1)*charge(2)
   vyp=0.5*wgh*vp(2)                !q*Dt*Vy time level t^(n+1/2)

   ax=shx+dx_inv*(xp0(1)-xmn)
   i0=int(ax+0.5)
   sx=ax-real(i0,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)

   ax=shx+dx_inv*(xp1(1)-xmn)
   i=int(ax+0.5)
   sx=ax-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   axh(0:4)=0.0
   !-----------------------
   ih=i-i0+1
   do i1=0,2
    axh(ih+i1)=ax1(i1)
   end do
   i=i-1
   i0=i0-1

   dcurrx(0)=-axh(0)
   do i1=1,3
    dcurrx(i1)=ax0(i1-1)-axh(i1)
   end do
   dcurrx(4)=-axh(4)
   dcurrx(0:4)=wgh*dcurrx(0:4)
   ih=i0-1
   do i1=0,4
    i2=ih+i1
    jc(i2,1,1,1)=jc(i2,1,1,1)+dcurrx(i1)
   end do
   !++++++++++++++
   ! jc(1)=[rho_old-rho_new]=dt*Der_xJ_x
   ! Jx has to be computed by inversion on the x-grid
   !=============================
   do i1=0,2
    i2=i0+i1-1
    jc(i2,1,1,2)=jc(i2,1,1,2)+vyp*ax0(i1)
    i2=i+i1-1
    jc(i2,1,1,2)=jc(i2,1,1,2)+vyp*ax1(i1)
   end do
  end do
  !======================
 case(2)
  if(njc==2)then
   do n=n0,np
    part(2,n)=sp_loc%part(n)%cmp(2) !y-new  t^(n+1)
    xp1(1)=sp_loc%part(n)%cmp(1)    !x-new  t^(n+1)
    xp0(1)=part(3,n)                !x-old
    part(1,n)=dx_inv*(xp1(1)-xmn)
    part(3,n)=dx_inv*(xp0(1)-xmn)
   end do
   if(n_st==0)then
    do n=1,np
     xp1(2)=part(2,n)                !y-new
     xp0(2)=part(4,n)                !y-old
     part(2,n)=dy_inv*(xp1(2)-ymn)
     part(4,n)=dy_inv*(xp0(2)-ymn)
    end do
   else
    call map2dy_part_sind(np,n_st,2,ymn,part)
    call map2dy_part_sind(np,n_st,4,ymn,part)
   endif
   do n=n0,np
    xp1(1:2)=part(1:2,n)                !x-new
    xp0(1:2)=part(3:4,n)                !x-old
    wgh=sp_loc%part(n)%cmp(5)
    wgh=charge(1)*charge(2)
    !=====================
    ax=shx+xp0(1)
    i0=int(ax+0.5)
    sx=ax-real(i0,dp)
    sx2=sx*sx
    ax0(1)=0.75-sx2
    ax0(2)=0.5*(0.25+sx2+sx)
    ax0(0)=1.-ax0(1)-ax0(2)

    ax=shx+xp1(1)
    i=int(ax+0.5)
    sx=ax-real(i,dp)
    sx2=sx*sx
    ax1(1)=0.75-sx2
    ax1(2)=0.5*(0.25+sx2+sx)
    ax1(0)=1.-ax1(1)-ax1(2)
    axh(0:4)=0.0
    ih=i-i0+1
    do i1=0,2
     axh(ih+i1)=ax1(i1)
    end do
    dcurrx(0)=-axh(0)
    dcurrx(1:3)=ax0(0:2)-axh(1:3)
    dcurrx(4)=-axh(4)
    do i1=1,3
     axh(i1)=axh(i1)+ax0(i1-1)
    end do
    dcurrx(0:4)=wgh*dcurrx(0:4)
    ix0=min(ih,1)
    ix1=max(ih+2,3)
    !-------
    ax=shy+xp0(2)
    j0=int(ax+0.5)
    sx=ax-real(j0,dp)
    sx2=sx*sx
    ay0(1)=0.75-sx2
    ay0(2)=0.5*(0.25+sx2+sx)
    ay0(0)=1.-ay0(1)-ay0(2)

    ax=shy+xp1(2)
    j=int(ax+0.5)
    sx=ax-real(j,dp)
    sx2=sx*sx
    ay1(1)=0.75-sx2
    ay1(2)=0.5*(0.25+sx2+sx)
    ay1(0)=1.-ay1(1)-ay1(2)

    jh=j-j0+1
    ayh(0:4)=0.0
    do i1=0,2
     ayh(jh+i1)=ay1(i1)
    end do
    curry(0)=-ayh(0)
    do i1=1,3
     curry(i1)=curry(i1-1)+ay0(i1-1)-ayh(i1)
    end do
    curry(4)=curry(3)-ayh(4)
    curry(0:4)=wgh*curry(0:4)
    !========================================
    do i1=1,3
     ayh(i1)=ayh(i1)+ay0(i1-1)
    end do
    iy0=min(jh,1)
    iy1=max(jh+2,3)
    !================dt*J_x
    j0=j0-1
    j=j-1
    jh=j0-1

    i=i-1
    i0=i0-1
    ih=i0-1

    do j1=iy0,iy1
     j2=jh+j1
     do i1=ix0,ix1
      i2=ih+i1
      jc(i2,j2,1,1)=jc(i2,j2,1,1)+ayh(j1)*dcurrx(i1)
     end do
    end do
    !================dt*J_y
    do j1=iy0,iy1
     j2=jh+j1
     do i1=ix0,ix1
      i2=ih+i1
      jc(i2,j2,1,2)=jc(i2,j2,1,2)+axh(i1)*curry(j1)
     end do
    end do
   end do
  endif
  if(njc==3)then
   do n=n0,np
    part(2:3,n)=sp_loc%part(n)%cmp(2:3) !yz-new  t^(n+1)
    xp1(1)=sp_loc%part(n)%cmp(1)    !x-new
    xp0(1)=part(4,n)                !x-old
    part(1,n)=dx_inv*(xp1(1)-xmn)
    part(4,n)=dx_inv*(xp0(1)-xmn)
   end do
   if(n_st==0)then
    do n=n0,np
     xp1(2)=part(2,n)                !y-new
     xp0(2)=part(5,n)                !y-old
     part(2,n)=dy_inv*(xp1(2)-ymn)
     part(5,n)=dy_inv*(xp0(2)-ymn)
    end do
   else
    call map2dy_part_sind(np,n_st,2,ymn,part)
    call map2dy_part_sind(np,n_st,5,ymn,part)
   endif
   do n=n0,np
    xp1(1:3)=part(1:3,n)                !increments xy-new
    xp0(1:3)=part(4:6,n)                !increments xy and z-old
    wgh=sp_loc%part(n)%cmp(7)
    wgh=charge(1)*charge(2)
    vp(3)=xp1(3)-xp0(3)                    !dt*v_z(n+1/2)
    vp(3)=wgh*vp(3)/3.                     !dt*vz/3
    !=====================
    ax=shx+xp0(1)
    i0=int(ax+0.5)
    sx=ax-real(i0,dp)
    sx2=sx*sx
    ax0(1)=0.75-sx2
    ax0(2)=0.5*(0.25+sx2+sx)
    ax0(0)=1.-ax0(1)-ax0(2)

    ax=shx+xp1(1)
    i=int(ax+0.5)
    sx=ax-real(i,dp)
    sx2=sx*sx
    ax1(1)=0.75-sx2
    ax1(2)=0.5*(0.25+sx2+sx)
    ax1(0)=1.-ax1(1)-ax1(2)
    axh(0:4)=0.0
    ih=i-i0+1
    ix0=min(ih,1)
    ix1=max(ih+2,3)
    do i1=0,2
     axh(ih+i1)=ax1(i1)
    end do
    dcurrx(0)=-axh(0)
    dcurrx(1:3)=ax0(0:2)-axh(1:3)
    dcurrx(4)=-axh(4)
    dcurrx(0:4)=wgh*dcurrx(0:4)

    axh0(0:4)=0.5*axh(0:4)
    axh1(0:4)=axh(0:4)
    do i1=1,3
     axh0(i1)=axh0(i1)+ax0(i1-1)
     axh1(i1)=axh1(i1)+0.5*ax0(i1-1)
     axh(i1)=axh(i1)+ax0(i1-1)         !Wx^0+Wx^1)
    end do
    !-------
    i=i-1
    i0=i0-1

    ax=shy+xp0(2)
    j0=int(ax+0.5)
    sx=ax-real(j0,dp)
    sx2=sx*sx
    ay0(1)=0.75-sx2
    ay0(2)=0.5*(0.25+sx2+sx)
    ay0(0)=1.-ay0(1)-ay0(2)

    ax=shy+xp1(2)
    j=int(ax+0.5)
    sx=ax-real(j,dp)
    sx2=sx*sx
    ay1(1)=0.75-sx2
    ay1(2)=0.5*(0.25+sx2+sx)
    ay1(0)=1.-ay1(1)-ay1(2)

    jh=j-j0+1
    iy0=min(jh,1)
    iy1=max(jh+2,3)

    ayh(0:4)=0.0
    do i1=0,2
     ayh(jh+i1)=ay1(i1)
    end do
    curry(0)=-ayh(0)
    do i1=1,3
     curry(i1)=curry(i1-1)+ay0(i1-1)-ayh(i1)
    end do
    curry(4)=curry(3)-ayh(4)
    curry(0:4)=wgh*curry(0:4)
    do i1=1,3
     ayh(i1)=ayh(i1)+ay0(i1-1)
    end do
    !-----------
    j0=j0-1
    j=j-1
    !================dt*J_x= currx*(Wy^0+Wy^1) to be multiplied by dx/2
    ih=i0-1
    jh=j0-1
    do j1=iy0,iy1
     j2=jh+j1
     do i1=ix0,ix1
      i2=ih+i1
      jc(i2,j2,1,1)=jc(i2,j2,1,1)+ayh(j1)*dcurrx(i1)
     end do
    end do
    !================dt*J_y= curry*(Wx^0+Wx^1)
    do j1=iy0,iy1
     j2=jh+j1
     do i1=ix0,ix1
      i2=ih+i1
      jc(i2,j2,1,2)=jc(i2,j2,1,2)+axh(i1)*curry(j1)
     end do
    end do
    !========== dt*J_z Vz*[Wy^0(Wx^0+0.5*Wx^1)+Wy^1*(Wx^1+0.5*Wx^0)]
    do j1=0,2
     j2=j0+j1
     dvol=ay0(j1)*vp(3)
     do i1=ix0,ix1
      i2=i1+ih
      jc(i2,j2,1,3)=jc(i2,j2,1,3)+axh0(i1)*dvol
     end do
     j2=j+j1
     dvol=ay1(j1)*vp(3)
     do i1=ix0,ix1
      i2=i1+ih
      jc(i2,j2,1,3)=jc(i2,j2,1,3)+axh1(i1)*dvol
     end do
    end do
   end do
  endif
 end select
 !-----------------------
 end subroutine pdef_2d_curr
 !=============3D=================
 subroutine esirkepov_3d_curr(sp_loc,part,n0,np,s_ind,xmn,ymn,zmn)

 type(species),intent(in) :: sp_loc
 real(dp),intent(inout) :: part(:,:)
 integer,intent(in) :: n0,np,s_ind
 real(dp),intent(in) :: xmn,ymn,zmn
 real(dp) :: ax,sx,sx2,dvol,dvolh,wgh
 real(dp) :: ax0(0:2),ay0(0:2),az0(0:2),xp1(3),xp0(3)
 real(dp) :: ax1(0:2),ay1(0:2),az1(0:2)
 real(dp) :: axh(0:4),ayh(0:4),azh(0:4)
 real(dp) :: axh0(0:4),axh1(0:4),ayh0(0:4),ayh1(0:4)
 real(dp) :: currx(0:4),curry(0:4),currz(0:4)
 integer :: i,j,k,i0,j0,k0,i1,j1,k1,i2,j2,k2,n
 integer :: ih,jh,kh
 integer :: ix0,ix1,iy0,iy1,iz0,iz1
 !=======================
 real(sp) :: charge(2),wgh4
 equivalence(charge,wgh)

 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0;az0(0:2)=0.0
 ax0(0:2)=0.0;ay0(0:2)=0.0
 axh(0:4)=0.0;ayh(0:4)=0.0
 azh(0:4)=0.0
 currx(0:4)=0.0;curry(0:4)=0.0
 currz(0:4)=0.0
 axh0(0:4)=0.0;ayh0(0:4)=0.0
 axh1(0:4)=0.0;ayh1(0:4)=0.0

 do n=n0,np
  part(1:3,n)=sp_loc%part(n)%cmp(1:3)  !xyz new
  part(1,n)=dx_inv*(part(1,n)-xmn)
  part(4,n)=dx_inv*(part(4,n)-xmn) !x-old
 end do
 if(s_ind==0)then
  do n=n0,np
   xp1(2:3)=part(2:3,n)               !yz-new positions
   xp0(2:3)=part(5:6,n)               !yz-old positions
   part(2,n)=dy_inv*(xp1(2)-ymn)
   part(3,n)=dz_inv*(xp1(3)-zmn)
   part(5,n)=dy_inv*(xp0(2)-ymn)
   part(6,n)=dz_inv*(xp0(3)-zmn)
  end do
 else
  call map3d_part_sind(part,np,s_ind,2,3,ymn,zmn)
  call map3d_part_sind(part,np,s_ind,5,6,ymn,zmn)
 endif
 do n=n0,np
  xp1(1:3)=part(1:3,n)                !increments of the new positions
  xp0(1:3)=part(4:6,n)                !increments of old positions
  wgh=sp_loc%part(n)%cmp(7)
  wgh4=charge(1)*charge(2)

  ax=shx+xp0(1)
  i0=int(ax+0.5)
  sx=ax-real(i0,dp)
  sx2=sx*sx
  ax0(1)=0.75-sx2
  ax0(2)=0.5*(0.25+sx2+sx)
  ax0(0)=1.-ax0(1)-ax0(2)

  ax=shx+xp1(1)
  i=int(ax+0.5)
  sx=ax-real(i,dp)
  sx2=sx*sx
  ax1(1)=0.75-sx2
  ax1(2)=0.5*(0.25+sx2+sx)
  ax1(0)=1.-ax1(1)-ax1(2)
  axh(0:4)=0.0
  ih=i-i0+1
  !========== direct Jx-inversion
  do i1=0,2
   axh(ih+i1)=ax1(i1)
  end do
  currx(0)=-axh(0)
  do i1=1,3
   currx(i1)=currx(i1-1)+ax0(i1-1)-axh(i1)
  end do
  currx(4)=currx(3)-axh(4)
  currx(0:4)=wgh4*currx(0:4)
  !=======================
  axh0(0:4)=0.5*axh(0:4)
  axh1(0:4)=axh(0:4)
  do i1=1,3
   axh0(i1)=axh0(i1)+ax0(i1-1)
   axh1(i1)=axh1(i1)+0.5*ax0(i1-1)
  end do

  ix0=min(ih,1)
  ix1=max(ih+2,3)
  ! 3 data ih=1 [i0-1:i0+1] (no cell cross)
  ! 4 data ih=0 [i0-2:i0+1] ih=2 [i0-1:i0+2](cell cross)
  !-------
  i=i-1
  i0=i0-1

  ax=shy+xp0(2)
  j0=int(ax+0.5)
  sx=ax-real(j0,dp)
  sx2=sx*sx
  ay0(1)=0.75-sx2
  ay0(2)=0.5*(0.25+sx2+sx)
  ay0(0)=1.-ay0(1)-ay0(2)

  ax=shy+xp1(2)
  j=int(ax+0.5)
  sx=ax-real(j,dp)
  sx2=sx*sx
  ay1(1)=0.75-sx2
  ay1(2)=0.5*(0.25+sx2+sx)
  ay1(0)=1.-ay1(1)-ay1(2)

  !========== direct Jy-inversion
  jh=j-j0+1 !=[0,1,2]
  ayh(0:4)=0.0
  do i1=0,2
   ayh(jh+i1)=ay1(i1)
  end do
  curry(0)=-ayh(0)
  do i1=1,3
   curry(i1)=curry(i1-1)+ay0(i1-1)-ayh(i1)
  end do
  curry(4)=curry(3)-ayh(4)
  curry(0:4)=wgh4*curry(0:4)
  !=====================================
  !                                 Jx =>    Wz^0(0.5*wy^1+Wy^0)=Wz^0*ayh0
  !                                          Wz^1(wy^1+0.5*Wy^0)=Wz^1*ayh1
  !==============================
  ayh0(0:4)=0.5*ayh(0:4)
  ayh1(0:4)=ayh(0:4)
  do i1=1,3
   ayh0(i1)=ayh0(i1)+ay0(i1-1)
   ayh1(i1)=ayh1(i1)+0.5*ay0(i1-1)
  end do
  iy0=min(jh,1) ![0,1]
  iy1=max(jh+2,3)![3,4]
  !-----------
  j0=j0-1
  j=j-1

  ax=shz+xp0(3)
  k0=int(ax+0.5)
  sx=ax-real(k0,dp)
  sx2=sx*sx
  az0(1)=0.75-sx2
  az0(2)=0.5*(0.25+sx2+sx)
  az0(0)=1.-az0(1)-az0(2)

  ax=shz+xp1(3)
  k=int(ax+0.5)
  sx=ax-real(k,dp)
  sx2=sx*sx
  az1(1)=0.75-sx2
  az1(2)=0.5*(0.25+sx2+sx)
  az1(0)=1.-az1(1)-az1(2)
  ! Direct Jz inversion
  kh=k-k0+1
  azh(0:4)=0.0
  do i1=0,2
   azh(kh+i1)=az1(i1)
  end do
  currz(0)=-azh(0)
  do i1=1,3
   currz(i1)=currz(i1-1)+az0(i1-1)-azh(i1)
  end do
  currz(4)=currz(3)-azh(4)
  currz(0:4)=wgh4*currz(0:4)
  !----------
  k0=k0-1
  k=k-1
  iz0=min(kh,1)
  iz1=max(kh+2,3)
  !================Jx=DT*drho_x to be inverted==================
  jh=j0-1
  !====================
  ih=i0-1
  do k1=0,2
   do j1=iy0,iy1
    j2=jh+j1
    dvol=ayh0(j1)*az0(k1)
    dvolh=ayh1(j1)*az1(k1)
    do i1=ix0,ix1
     i2=ih+i1
     jc(i2,j2,k0+k1,1)=jc(i2,j2,k0+k1,1)+dvol*currx(i1)
     jc(i2,j2,k+k1,1)=jc(i2,j2,k+k1,1)+dvolh*currx(i1)
    end do
   end do
  end do
  !================Jy
  do k1=0,2
   do j1=iy0,iy1
    j2=jh+j1
    dvol=curry(j1)*az0(k1)
    dvolh=curry(j1)*az1(k1)
    do i1=ix0,ix1
     i2=ih+i1
     jc(i2,j2,k0+k1,2)=jc(i2,j2,k0+k1,2)+axh0(i1)*dvol
     jc(i2,j2,k+k1,2)=jc(i2,j2,k+k1,2)+axh1(i1)*dvolh
    end do
   end do
  end do
  !================Jz
  kh=k0-1

  do k1=iz0,iz1
   k2=kh+k1
   do j1=0,2
    dvol=ay0(j1)*currz(k1)
    dvolh=ay1(j1)*currz(k1)
    do i1=ix0,ix1
     i2=ih+i1
     jc(i2,j0+j1,k2,3)=jc(i2,j0+j1,k2,3)+axh0(i1)*dvol
     jc(i2,j+j1,k2,3)=jc(i2,j+j1,k2,3)+axh1(i1)*dvolh
    end do
   end do
  end do
 end do
 !============= Curr data on [1:n+4] extended range
 end subroutine esirkepov_3d_curr
 !===============================
 subroutine pdef_3d_curr(sp_loc,part,n0,np,s_ind,xmn,ymn,zmn)

 type(species),intent(in) :: sp_loc
 real(dp),intent(inout) :: part(:,:)
 integer,intent(in) :: n0,np,s_ind
 real(dp),intent(in) :: xmn,ymn,zmn
 real(dp) :: ax,sx,sx2,dvol,dvolh,wgh
 real(dp) :: ax0(0:2),ay0(0:2),az0(0:2),xp1(3),xp0(3)
 real(dp) :: ax1(0:2),ay1(0:2),az1(0:2)
 real(dp) :: axh(0:4),ayh(0:4),azh(0:4)
 real(dp) :: axh0(0:4),axh1(0:4),ayh0(0:4),ayh1(0:4)
 real(dp) :: dcurrx(0:4),curry(0:4),currz(0:4)
 integer :: i,j,k,i0,j0,k0,i1,j1,k1,i2,j2,k2,n
 integer :: ih,jh,kh
 integer :: ix0,ix1,iy0,iy1,iz0,iz1
 !=======================
 real(sp) :: charge(2)
 equivalence(charge,wgh)

 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0;az0(0:2)=0.0
 ax0(0:2)=0.0;ay0(0:2)=0.0
 axh(0:4)=0.0;ayh(0:4)=0.0
 azh(0:4)=0.0
 dcurrx(0:4)=0.0;curry(0:4)=0.0
 currz(0:4)=0.0
 axh0(0:4)=0.0;ayh0(0:4)=0.0
 axh1(0:4)=0.0;ayh1(0:4)=0.0

 do n=n0,np
  part(1:3,n)=sp_loc%part(n)%cmp(1:3)  !xyz new
  part(1,n)=dx_inv*(part(1,n)-xmn)
  part(4,n)=dx_inv*(part(4,n)-xmn)
 end do
 if(s_ind==0)then
  do n=n0,np
   xp1(2:3)=part(2:3,n)               !yz-new positions
   xp0(2:3)=part(5:6,n)               !yz-old positions
   part(2,n)=dy_inv*(xp1(2)-ymn)
   part(3,n)=dz_inv*(xp1(3)-zmn)
   part(5,n)=dy_inv*(xp0(2)-ymn)
   part(6,n)=dz_inv*(xp0(3)-zmn)
  end do
 else
  call map3d_part_sind(part,np,s_ind,2,3,ymn,zmn)
  call map3d_part_sind(part,np,s_ind,5,6,ymn,zmn)
 endif
 do n=n0,np
  xp1(1:3)=part(1:3,n)                !increments of the new positions
  xp0(1:3)=part(4:6,n)                !increments of old positions
  wgh=sp_loc%part(n)%cmp(7)
  wgh=charge(1)*charge(2)

  ax=shx+xp0(1)
  i0=int(ax+0.5)
  sx=ax-real(i0,dp)
  sx2=sx*sx
  ax0(1)=0.75-sx2
  ax0(2)=0.5*(0.25+sx2+sx)
  ax0(0)=1.-ax0(1)-ax0(2)

  ax=shx+xp1(1)
  i=int(ax+0.5)
  sx=ax-real(i,dp)
  sx2=sx*sx
  ax1(1)=0.75-sx2
  ax1(2)=0.5*(0.25+sx2+sx)
  ax1(0)=1.-ax1(1)-ax1(2)
  axh(0:4)=0.0
  ih=i-i0+1        ![0,1,2]
  do i1=0,2
   axh(ih+i1)=ax1(i1)
  end do
  dcurrx(0)=-axh(0)
  do i1=1,3
   dcurrx(i1)=ax0(i1-1)-axh(i1)
  end do
  dcurrx(4)=-axh(4)
  dcurrx(0:4)=wgh*dcurrx(0:4)

  axh0(0:4)=0.5*axh(0:4)
  axh1(0:4)=axh(0:4)
  do i1=1,3
   axh0(i1)=axh0(i1)+ax0(i1-1)
   axh1(i1)=axh1(i1)+0.5*ax0(i1-1)
  end do

  ix0=min(ih,1)
  ix1=max(ih+2,3)
  ! 3 data ih=1 [i0-1:i0+1] (no cell cross)
  ! 4 data ih=0 [i0-2:i0+1] ih=2 [i0-1:i0+2](cell cross)
  !-------
  i=i-1
  i0=i0-1

  ax=shy+xp0(2)
  j0=int(ax+0.5)
  sx=ax-real(j0,dp)
  sx2=sx*sx
  ay0(1)=0.75-sx2
  ay0(2)=0.5*(0.25+sx2+sx)
  ay0(0)=1.-ay0(1)-ay0(2)

  ax=shy+xp1(2)
  j=int(ax+0.5)
  sx=ax-real(j,dp)
  sx2=sx*sx
  ay1(1)=0.75-sx2
  ay1(2)=0.5*(0.25+sx2+sx)
  ay1(0)=1.-ay1(1)-ay1(2)

  jh=j-j0+1    !=[0,1,2]
  ayh(0:4)=0.0
  do i1=0,2
   ayh(jh+i1)=ay1(i1)
  end do
  curry(0)=-ayh(0)
  do i1=1,3
   curry(i1)=curry(i1-1)+ay0(i1-1)-ayh(i1)
  end do
  curry(4)=curry(3)-ayh(4)
  curry(0:4)=wgh*curry(0:4)
  !=====================================
  ! Jx => Wz^0(0.5*wy^1+Wy^0)=Wz^0*ayh0
  ! Wz^1(wy^1+0.5*Wy^0)=Wz^1*ayh1
  !==============================
  ayh0(0:4)=0.5*ayh(0:4)
  ayh1(0:4)=ayh(0:4)
  do i1=1,3
   ayh0(i1)=ayh0(i1)+ay0(i1-1)
   ayh1(i1)=ayh1(i1)+0.5*ay0(i1-1)
  end do
  iy0=min(jh,1) ![0,1]
  iy1=max(jh+2,3)![3,4]
  !-----------
  j0=j0-1
  j=j-1

  ax=shz+xp0(3)
  k0=int(ax+0.5)
  sx=ax-real(k0,dp)
  sx2=sx*sx
  az0(1)=0.75-sx2
  az0(2)=0.5*(0.25+sx2+sx)
  az0(0)=1.-az0(1)-az0(2)

  ax=shz+xp1(3)
  k=int(ax+0.5)
  sx=ax-real(k,dp)
  sx2=sx*sx
  az1(1)=0.75-sx2
  az1(2)=0.5*(0.25+sx2+sx)
  az1(0)=1.-az1(1)-az1(2)
  kh=k-k0+1
  azh(0:4)=0.0
  do i1=0,2
   azh(kh+i1)=az1(i1)
  end do
  currz(0)=-azh(0)
  do i1=1,3
   currz(i1)=currz(i1-1)+az0(i1-1)-azh(i1)
  end do
  currz(4)=currz(3)-azh(4)
  currz(0:4)=wgh*currz(0:4)
  !----------
  k0=k0-1
  k=k-1
  iz0=min(kh,1)
  iz1=max(kh+2,3)
  !================Jx=DT*drho_x to be inverted==================
  jh=j0-1
  !====================
  ih=i0-1
  do k1=0,2
   do j1=iy0,iy1
    j2=jh+j1
    dvol=ayh0(j1)*az0(k1)
    dvolh=ayh1(j1)*az1(k1)
    do i1=ix0,ix1
     i2=ih+i1
     jc(i2,j2,k0+k1,1)=jc(i2,j2,k0+k1,1)+dvol*dcurrx(i1)
     jc(i2,j2,k+k1,1)=jc(i2,j2,k+k1,1)+dvolh*dcurrx(i1)
    end do
   end do
  end do
  !================Jy
  do k1=0,2
   do j1=iy0,iy1
    j2=jh+j1
    dvol=curry(j1)*az0(k1)
    dvolh=curry(j1)*az1(k1)
    do i1=ix0,ix1
     i2=ih+i1
     jc(i2,j2,k0+k1,2)=jc(i2,j2,k0+k1,2)+axh0(i1)*dvol
     jc(i2,j2,k+k1,2)=jc(i2,j2,k+k1,2)+axh1(i1)*dvolh
    end do
   end do
  end do
  !================Jz
  kh=k0-1

  do k1=iz0,iz1
   k2=kh+k1
   do j1=0,2
    dvol=ay0(j1)*currz(k1)
    dvolh=ay1(j1)*currz(k1)
    do i1=ix0,ix1
     i2=ih+i1
     jc(i2,j0+j1,k2,3)=jc(i2,j0+j1,k2,3)+axh0(i1)*dvol
     jc(i2,j+j1,k2,3)=jc(i2,j+j1,k2,3)+axh1(i1)*dvolh
    end do
   end do
  end do
 end do
 !============= Curr data on [1:n+4] extended range
 end subroutine pdef_3d_curr
 !===================================
 !=====================================
 subroutine ionization_energy(ef,curr,part,np,ndm,xmn,ymn,zmn)

 real(dp),intent(in) :: part(:,:)
 real(dp),intent(inout) :: ef(:,:,:,:),curr(:,:,:,:)
 integer,intent(in) :: np,ndm
 ! real(dp),intent(in) :: dt_loc
 real(dp),intent(in) :: xmn,ymn,zmn
 real(dp) :: ax1(0:2),ay1(0:2),az1(0:2)
 real(dp) :: axh(0:2),ayh(0:2),azh(0:2),gx(0:2,0:2),gy(0:2,0:2)
 real(dp) :: xx,sx,sx2,energy_loss,xp1(3),emod,dvol
 integer :: i,ih,i1,i2,ih2,j,jh,j1,j2,jh2,k,kh,k1,k2,n
 !==============================
 select case(ndm)
 case(2)
  k2=1
  emod=1.
  do n=1,np
   xp1(1)=dx_inv*(part(1,n)-xmn)
   xp1(2)=dy_inv*(part(2,n)-ymn)
   energy_loss=part(5,n)

   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   ih=int(xx)
   sx=xx-0.5-real(ih,dp)
   sx2=sx*sx
   axh(1)=0.75-sx2
   axh(2)=0.5*(0.25+sx2+sx)
   axh(0)=1.-axh(1)-axh(2)
   !axh(1)=sx+0.5
   !axh(0)=1.-axh(1)

   xx=shx+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)
   jh=int(xx)
   sx=xx-0.5-real(jh,dp)
   sx2=sx*sx
   ayh(1)=0.75-sx2
   ayh(2)=0.5*(0.25+sx2+sx)
   ayh(0)=1.-ayh(1)-ayh(2)

   !ayh(1)=sx+0.5
   !ayh(0)=1.-ayh(1)

   i=i-1
   j=j-1
   ih=ih-1
   jh=jh-1
   do j1=0,2
    do i1=0,2
     gx(i1,j1)=energy_loss*axh(i1)*ay1(j1)
    end do
   end do
   do j1=0,2
    do i1=0,2
     gy(i1,j1)=energy_loss*ax1(i1)*ayh(j1)
    end do
   end do

   do j1=0,2
    j2=j+j1
    jh2=jh+j1
    do i1=0,2
     ih2=ih+i1
     i2=i+i1
     emod=ef(ih2,j2,k2,1)*ef(ih2,j2,k2,1)+ef(i2,jh2,k2,2)*ef(i2,j2,k2,2)
     jc(ih2,j2,k2,1)=jc(ih2,j2,k2,1)+ef(ih2,j2,k2,1)*gx(i1,j1)/emod
     jc(i2,jh2,k2,2)=jc(i2,jh2,k2,2)+ef(i2,jh2,k2,2)*gy(i1,j1)/emod
    end do
   end do
  end do
 case(3)
  do n=1,np
   xp1(1)=dx_inv*(part(1,n)-xmn)
   xp1(2)=dy_inv*(part(2,n)-ymn)
   xp1(3)=dz_inv*(part(3,n)-zmn)

   energy_loss=part(7,n)
   xx=shx+xp1(1)
   i=int(xx+0.5)
   sx=xx-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   axh(1)=sx+0.5
   axh(0)=1.-axh(1)

   xx=shx+xp1(2)
   j=int(xx+0.5)
   sx=xx-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   ayh(1)=sx+0.5
   ayh(0)=1.-ayh(1)

   xx=shz+xp1(3)
   k=int(xx+0.5)
   sx=xx-real(k,dp)
   sx2=sx*sx
   az1(1)=0.75-sx2
   az1(2)=0.5*(0.25+sx2+sx)
   az1(0)=1.-az1(1)-az1(2)

   azh(1)=sx+0.5
   azh(0)=1.-azh(1)

   i=i-1
   j=j-1
   k=k-1

   ih=i
   jh=j
   kh=k

   do k1=0,2
    k2=k+k1
    do j1=0,2
     j2=j+j1
     dvol=energy_loss*ay1(j1)*az1(k1)
     do i1=0,1
      i2=ih+i1
      curr(i2,j2,k2,1)=curr(i2,j2,k2,1)+ef(i2,j2,k2,1)*dvol*axh(i1)
     end do
    end do
    do j1=0,1
     j2=jh+j1
     dvol=energy_loss*ayh(j1)*az1(k1)
     do i1=0,2
      i2=i+i1
      curr(i2,j2,k2,2)=curr(i2,j2,k2,2)+ef(i2,j2,k2,2)*dvol*ax1(i1)
     end do
    end do
   end do
   do k1=0,1
    k2=kh+k1
    do j1=0,2
     j2=j+j1
     dvol=energy_loss*ay1(j1)*azh(k1)
     do i1=0,2
      i2=i+i1
      curr(i2,j2,k2,3)=curr(i2,j2,k2,3)+ef(i2,j2,k2,3)*dvol*ax1(i1)
     end do
    end do
   end do
  end do
 end select
 !==============
 end subroutine ionization_energy
 !======================
 ! NO CHARGE PRESERVING SCHEMES
 !=========================
 subroutine ncdef_2d_curr(loc_sp,part,n0,np,s_ind,njc,ndm,xmn,ymn)

 type(species),intent(in) :: loc_sp
 real(dp),intent(inout) :: part(:,:)
 integer,intent(in) :: n0,np,s_ind,njc,ndm
 ! real(dp),intent(in) :: dt_loc
 real(dp),intent(in) :: xmn,ymn
 real(dp) :: ax,sx,sx2,wgh,gam_inv
 real(dp) :: axh0(0:1),axh1(0:1),ayh0(0:1),ayh1(0:1)
 real(dp) :: ax0(0:2),ay0(0:2),xp1(3),xp0(3)
 real(dp) :: ax1(0:2),ay1(0:2),vp(3),dvolh,dvol(1:3)
 integer :: i,j,i0,j0,i1,j1,i2,j2,n
 integer :: ih0,jh0,ih,jh
 !=======================
 real(sp) :: charge(2)
 equivalence(charge,wgh)

 if(ndm <2)then
  j2=1
  do n=n0,np
   xp1(1:2)=loc_sp%part(n)%cmp(1:2)  !(x,y) new
   vp(1:2)=loc_sp%part(n)%cmp(3:4)  !(Px,Py) momenta
   wgh=loc_sp%part(n)%cmp(5)
   wgh=charge(1)*charge(2)
   gam_inv=part(5,n)           !stores dt/gam
   vp(1:2)=0.5*wgh*gam_inv*vp(1:2) !1/2 *V* q*dt
   xp1(1)=dx_inv*(xp1(1)-xmn)                !new positions
   xp0(1)=dx_inv*(part(3,n)-xmn)                !old positions

   ax=shx+xp0(1)
   i0=int(ax+0.5)
   sx=ax-real(i0,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)
   axh0(1)=sx+0.5
   axh0(0)=1.-axh0(1)

   ax=shx+xp1(1)
   i=int(ax+0.5)
   sx=ax-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   axh1(1)=sx+0.5
   axh1(0)=1.-axh1(1)

   i=i-1
   i0=i0-1
   ih=i
   ih0=i0
   do i1=0,1
    i2=ih0+i1
    jc(i2,j2,1,1)=jc(i2,j2,1,1)+vp(1)*axh0(i1)
    i2=ih+i1
    jc(i2,j2,1,1)=jc(i2,j2,1,1)+vp(1)*axh1(i1)
   end do

   do i1=0,2
    i2=i0+i1
    jc(i2,j2,1,2)=jc(i2,j2,1,2)+vp(2)*ax0(i1)
    i2=i+i1
    jc(i2,j2,1,2)=jc(i2,j2,1,2)+vp(2)*ax1(i1)
   end do
  end do
  !=============
  return
 endif
 !==============================
 select case(njc)
 case(2)      !2D-2V
  do n=n0,np
   part(1:2,n)=loc_sp%part(n)%cmp(1:2)  !(x,y) new
   part(1,n)=dx_inv*(part(1,n)-xmn)
   part(3,n)=dx_inv*(part(3,n)-xmn)
  end do
  if(s_ind==0)then
   do n=1,np
    part(2,n)=dy_inv*(part(2,n)-ymn)   !y new
    part(4,n)=dy_inv*(part(4,n)-ymn)   !y-old
   end do
  else
   call map2dy_part_sind(np,s_ind,2,ymn,part)
   call map2dy_part_sind(np,s_ind,4,ymn,part)
  endif
  do n=n0,np
   vp(1:2)=loc_sp%part(n)%cmp(3:4)
   wgh=loc_sp%part(n)%cmp(5)
   wgh=charge(1)*charge(2)
   gam_inv=part(5,n)           !dt/gam
   vp(1:2)=0.5*wgh*gam_inv*vp(1:2)      !1/2 * V*wgh*dt
   xp1(1:2)=part(1:2,n)                !new positions
   xp0(1:2)=part(3:4,n)                !old positions

   ax=shx+xp0(1)
   i0=int(ax+0.5)
   sx=ax-real(i0,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)
   axh0(1)=sx+0.5
   axh0(0)=1.-axh0(1)

   ax=shx+xp1(1)
   i=int(ax+0.5)
   sx=ax-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   axh1(1)=sx+0.5
   axh1(0)=1.-axh1(1)

   i=i-1
   i0=i0-1
   ih=i
   ih0=i0

   ax=shy+xp0(2)
   j0=int(ax+0.5)
   sx=ax-real(j0,dp)
   sx2=sx*sx
   ay0(1)=0.75-sx2
   ay0(2)=0.5*(0.25+sx2+sx)
   ay0(0)=1.-ay0(1)-ay0(2)
   ayh0(1)=sx+0.5
   ayh0(0)=1.-ayh0(1)
   !=========
   ax=shy+xp1(2)
   j=int(ax+0.5)
   sx=ax-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)
   ayh1(1)=sx+0.5
   ayh1(0)=1.-ayh1(1)
   !-----------
   j0=j0-1
   j=j-1
   jh0=j0
   jh=j
   !===============[Jx Jy rho^(new}]==============
   do j1=0,2
    j2=j0+j1
    dvol(1)=vp(1)*ay0(j1)
    do i1=0,1
     i2=ih0+i1
     jc(i2,j2,1,1)=jc(i2,j2,1,1)+dvol(1)*axh0(i1)
    end do
    j2=j+j1
    dvol(1)=vp(1)*ay1(j1)
    do i1=0,1
     i2=ih+i1
     jc(i2,j2,1,1)=jc(i2,j2,1,1)+dvol(1)*axh1(i1)
    end do
   end do
   !=============
   do j1=0,1
    j2=jh0+j1
    dvol(2)=vp(2)*ayh0(j1)
    do i1=0,2
     i2=i0+i1
     jc(i2,j2,1,2)=jc(i2,j2,1,2)+dvol(2)*ax0(i1)
    end do
    j2=jh+j1
    dvol(2)=vp(2)*ayh1(j1)
    do i1=0,2
     i2=i+i1
     jc(i2,j2,1,2)=jc(i2,j2,1,2)+dvol(2)*ax1(i1)
    end do
   end do
  end do
  !==============
 case(3)  !2D +3V
  !===================
  do n=n0,np
   part(1:2,n)=loc_sp%part(n)%cmp(1:2)  !(x,y) new
   part(1,n)=dx_inv*(part(1,n)-xmn)
   part(4,n)=dx_inv*(part(4,n)-xmn)
  end do
  if(s_ind==0)then
   do n=n0,np
    xp1(2)=part(2,n)                !new y positions
    xp0(2)=part(5,n)                !old y positions
    part(2,n)=dy_inv*(xp1(2)-ymn)
    part(5,n)=dy_inv*(xp0(2)-ymn)
   end do
  else
   call map2dy_part_sind(np,s_ind,2,ymn,part)
   call map2dy_part_sind(np,s_ind,5,ymn,part)
  endif
  do n=n0,np
   xp1(1:2)=part(1:2,n)                !new (x,y) positions
   xp0(1:2)=part(4:5,n)                !old (x,y) positions

   vp(1:3)=loc_sp%part(n)%cmp(4:6)
   wgh=loc_sp%part(n)%cmp(7)
   wgh=charge(1)*charge(2)
   gam_inv=part(n,7)
   vp(1:3)=0.5*wgh*gam_inv*vp(1:3)

   ax=shx+xp0(1)
   i0=int(ax+0.5)
   sx=ax-real(i0,dp)
   sx2=sx*sx
   ax0(1)=0.75-sx2
   ax0(2)=0.5*(0.25+sx2+sx)
   ax0(0)=1.-ax0(1)-ax0(2)

   ax=shx+xp1(1)
   i=int(ax+0.5)
   sx=ax-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)

   i=i-1
   i0=i0-1

   ax=shy+xp0(2)
   j0=int(ax+0.5)
   sx=ax-real(j0,dp)
   sx2=sx*sx
   ay0(1)=0.75-sx2
   ay0(2)=0.5*(0.25+sx2+sx)
   ay0(0)=1.-ay0(1)-ay0(2)
   !=========
   ax=shy+xp1(2)
   j=int(ax+0.5)
   sx=ax-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)
   !-----------
   j0=j0-1
   j=j-1
   !===============[Jx Jy Jz rho]==================
   do j1=0,2
    j2=j0+j1
    dvol(1:3)=vp(1:3)*ay0(j1)
    do i1=0,2
     i2=i0+i1
     jc(i2,j2,1,1)=jc(i2,j2,1,1)+dvol(1)*ax0(i1)
     jc(i2,j2,1,2)=jc(i2,j2,1,2)+dvol(2)*ax0(i1)
     jc(i2,j2,1,3)=jc(i2,j2,1,3)+dvol(3)*ax0(i1)
    end do
    j2=j+j1
    dvol(1:3)=vp(1:3)*ay1(j1)
    dvolh=wgh*ay1(j1)
    do i1=0,2
     i2=i+i1
     jc(i2,j2,1,1)=jc(i2,j2,1,1)+dvol(1)*ax1(i1)
     jc(i2,j2,1,2)=jc(i2,j2,1,2)+dvol(2)*ax1(i1)
     jc(i2,j2,1,3)=jc(i2,j2,1,3)+dvol(3)*ax1(i1)
     jc(i2,j2,1,4)=jc(i2,j2,1,4)+dvolh*ax1(i1)
    end do
   end do
  end do
 end select
 !============= Curr data on [0:n+3] extended range
 end subroutine ncdef_2d_curr
 !===============
 !========================
 subroutine ncdef_3d_curr(sp_loc,part,n0,np,s_ind,xmn,ymn,zmn)

 type(species),intent(in) :: sp_loc
 real(dp),intent(inout) :: part(:,:)
 integer,intent(in) :: n0,np,s_ind
 ! real(dp),intent(in) :: dt_loc
 real(dp),intent(in) :: xmn,ymn,zmn
 real(dp) :: ax,sx,sx2,dvol(3),wgh,gam_inv
 real(dp) :: ax0(0:2),ay0(0:2),az0(0:2),xp1(3),xp0(3)
 real(dp) :: ax1(0:2),ay1(0:2),az1(0:2),vp(3)
 real(dp) :: axh0(0:1),axh1(0:1),ayh0(0:1),ayh1(0:1),azh0(0:1),azh1(0:1)
 integer :: i,j,k,i0,j0,k0,i1,j1,k1,i2,j2,k2,n
 integer :: ih,jh,kh,ih0,jh0,kh0,ib_ind
 !=======================
 real(sp) :: charge(2),wgh4
 equivalence(charge,wgh)
 !
 ! WARNING: NO X-stretch allowed
 ! Current densities defined by alternating order (quadratic/linear) shapes
 ib_ind=size(jc,4)
 ax1(0:2)=0.0;ay1(0:2)=0.0
 az1(0:2)=0.0;az0(0:2)=0.0
 ax0(0:2)=0.0;ay0(0:2)=0.0
 axh0(0:1)=0.0;ayh0(0:1)=0.0
 azh0(0:1)=0.0;azh1(0:1)=0.0
 axh1(0:1)=0.0;ayh1(0:1)=0.0

 do n=n0,np
  part(1:3,n)=sp_loc%part(n)%cmp(1:3)  !new positions  part(4) is the old x position
  part(1,n)=dx_inv*(part(1,n)-xmn)
  part(4,n)=dx_inv*(part(4,n)-xmn)     !old position
 end do
 if(s_ind==0)then
  do n=n0,np
   xp1(2:3)=part(2:3,n)                !new y-z positions
   xp0(2:3)=part(5:6,n)                !old y-z positions
   part(2,n)=dy_inv*(xp1(2)-ymn)
   part(3,n)=dz_inv*(xp1(3)-zmn)
   part(5,n)=dy_inv*(xp0(2)-ymn)
   part(6,n)=dz_inv*(xp0(3)-zmn)
  end do
 else
  call map3d_part_sind(part,np,s_ind,2,3,ymn,zmn)
  call map3d_part_sind(part,np,s_ind,5,6,ymn,zmn)
 endif
 do n=n0,np
  vp(1:3)=sp_loc%part(n)%cmp(4:6)     !Momenta
  wgh=sp_loc%part(n)%cmp(7)           !Weight
  wgh4=charge(1)*charge(2)            !q*w
  gam_inv=part(7,n)                   !dt*gam_inv
  vp(1:3)=0.5*wgh4*gam_inv*vp(1:3) !wgh*q*dt*V factor 1/2 for density average
  !================================== old  x^n
  ax=shx+part(4,n)
  i0=int(ax+0.5)
  sx=ax-real(i0,dp)
  sx2=sx*sx
  ax0(1)=0.75-sx2
  ax0(2)=0.5*(0.25+sx2+sx)
  ax0(0)=1.-ax0(1)-ax0(2)

  axh0(1)=sx+0.5
  axh0(0)=1.-axh0(1)
  !===================================== new x^{n+1}
  ax=shx+part(1,n)
  i=int(ax+0.5)
  sx=ax-real(i,dp)
  sx2=sx*sx
  ax1(1)=0.75-sx2
  ax1(2)=0.5*(0.25+sx2+sx)
  ax1(0)=1.-ax1(1)-ax1(2)

  axh1(1)=sx+0.5
  axh1(0)=1.-axh1(1)
  i=i-1
  i0=i0-1
  ih=i
  ih0=i0

  ax=shy+part(5,n)
  j0=int(ax+0.5)
  sx=ax-real(j0,dp)
  sx2=sx*sx
  ay0(1)=0.75-sx2
  ay0(2)=0.5*(0.25+sx2+sx)
  ay0(0)=1.-ay0(1)-ay0(2)
  ayh0(1)=sx+0.5
  ayh0(0)=1.-ayh0(1)
  !=========
  ax=shy+part(2,n)
  j=int(ax+0.5)
  sx=ax-real(j,dp)
  sx2=sx*sx
  ay1(1)=0.75-sx2
  ay1(2)=0.5*(0.25+sx2+sx)
  ay1(0)=1.-ay1(1)-ay1(2)

  ayh1(1)=sx+0.5
  ayh1(0)=1.-ayh1(1)
  !-----------
  j0=j0-1
  j=j-1
  jh=j
  jh0=j0

  ax=shz+part(6,n)
  k0=int(ax+0.5)
  sx=ax-real(k0,dp)
  sx2=sx*sx
  az0(1)=0.75-sx2
  az0(2)=0.5*(0.25+sx2+sx)
  az0(0)=1.-az0(1)-az0(2)

  azh0(1)=sx+0.5
  azh0(0)=1.-azh0(1)

  ax=shz+part(3,n)
  k=int(ax+0.5)
  sx=ax-real(k,dp)
  sx2=sx*sx
  az1(1)=0.75-sx2
  az1(2)=0.5*(0.25+sx2+sx)
  az1(0)=1.-az1(1)-az1(2)

  azh1(1)=sx+0.5
  azh1(0)=1.-azh1(1)

  k0=k0-1
  k=k-1
  kh=k
  kh0=k0
  !================Jx-Jy-Jz=============
  do k1=0,2
   k2=k0+k1
   do j1=0,2
    j2=j0+j1
    dvol(1)=vp(1)*ay0(j1)*az0(k1)
    do i1=0,1
     i2=ih0+i1
     jc(i2,j2,k2,1)=jc(i2,j2,k2,1)+dvol(1)*axh0(i1)
    end do
   end do
   do j1=0,1
    j2=jh0+j1
    dvol(2)=vp(2)*ayh0(j1)*az0(k1)
    do i1=0,2
     i2=i0+i1
     jc(i2,j2,k2,2)=jc(i2,j2,k2,2)+dvol(2)*ax0(i1)
    end do
   end do
   k2=k+k1
   do j1=0,2
    j2=j+j1
    dvol(1)=vp(1)*ay1(j1)*az1(k1)
    do i1=0,1
     i2=ih+i1
     jc(i2,j2,k2,1)=jc(i2,j2,k2,1)+dvol(1)*axh1(i1)
    end do
   end do
   do j1=0,1
    j2=jh+j1
    dvol(2)=vp(2)*ayh1(j1)*az1(k1)
    do i1=0,2
     i2=i+i1
     jc(i2,j2,k2,2)=jc(i2,j2,k2,2)+dvol(2)*ax1(i1)
    end do
   end do
  end do
  do k1=0,1
   k2=kh0+k1
   do j1=0,2
    j2=j0+j1
    dvol(3)=vp(3)*ay0(j1)*azh0(k1)
    do i1=0,2
     i2=i0+i1
     jc(i2,j2,k2,3)=jc(i2,j2,k2,3)+dvol(3)*ax0(i1)
    end do
   end do
   k2=kh+k1
   do j1=0,2
    j2=j+j1
    dvol(3)=vp(3)*ay1(j1)*azh1(k1)
    do i1=0,2
     i2=i+i1
     jc(i2,j2,k2,3)=jc(i2,j2,k2,3)+dvol(3)*ax1(i1)
    end do
   end do
  end do
  !============== rho^n
  if(ib_ind==4)then
   do k1=0,2
    k2=k+k1
    do j1=0,2
     j2=j+j1
     dvol(3)=wgh*ay0(j1)*az0(k1)
     do i1=0,2
      i2=i+i1
      jc(i2,j2,k2,ib_ind)=jc(i2,j2,k2,ib_ind)+dvol(3)*ax0(i1)
     end do
    end do
   end do
  endif
 end do
 !============= Curr and density data on [0:n+3] extended range
 end subroutine ncdef_3d_curr
 !==========================
 subroutine ncdef_rk_curr(part,curr,s_ind,np,ndm,xmn,ymn,zmn)

 real(dp),intent(inout) :: part(:,:)
 real(dp),intent(out) :: curr(:,:,:,:)
 integer,intent(in) :: s_ind,np,ndm
 real(dp),intent(in) :: xmn,ymn,zmn
 real(dp) :: ax,sx,sx2,dvolh,dvol(3)
 real(dp) :: ax1(0:2),ay1(0:2),az1(0:2),xp1(3),vp(3)
 real(dp) :: axh1(0:2),ayh1(0:2),azh1(0:2)
 integer :: i,ih,j,jh,k,kh,i1,j1,k1,i2,j2,k2,n
 !====================
 ! NON CONSERVATIVE CURRENTS J^{i-1}=<V^{i-1}*rho^{i-1}>
 !===========================
 select case(ndm)
 case(1)
  j2=1;k2=1
  do n=1,np
   xp1(1)=part(1,n)       !x-positions at current times (t^{i-1})
   vp(1:2)=part(3:4,n)    !wgh*dt_rk*velocity at current times t^{i-1}

   ax=shx+dx_inv*(xp1(1)-xmn)
   i=int(ax+0.5)
   sx=ax-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   !=====================
   ih=int(ax)
   sx=ax-0.5-real(ih,dp)
   sx2=sx*sx
   axh1(1)=0.75-sx2
   axh1(2)=0.5*(0.25+sx2+sx)
   axh1(0)=1.-axh1(1)-axh1(2)
   !=========
   i=i-1
   ih=ih-1
   do i1=0,2
    i2=ih+i1
    curr(i2,j2,k2,1)=curr(i2,j2,k2,1)+vp(1)*axh1(i1)
    i2=i+i1
    curr(i2,j2,k2,2)=curr(i2,j2,k2,2)+vp(2)*ax1(i1)
   end do
  end do
 case(2)
  k2=1
  if(s_ind==0)then
   do n=1,np
    part(2,n)=dy_inv*(part(2,n)-ymn)
   end do
  else
   call map2dy_part_sind(np,s_ind,2,ymn,part)
  endif
  do n=1,np
   xp1(1:2)=part(1:2,n)       !positions at current times (t^{i-1})
   vp(1:2)=part(3:4,n)        !wgh*dt_rk*velocity at current times t^{i-1}

   ax=shx+dx_inv*(xp1(1)-xmn)
   i=int(ax+0.5)
   sx=ax-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   axh1(1)=sx+0.5
   axh1(0)=1.-axh1(1)
   !=========
   ax=shy+xp1(2)
   j=int(ax+0.5)
   sx=ax-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)

   ayh1(1)=sx+0.5
   ayh1(0)=1.-ayh1(1)

   i=i-1
   ih=i
   j=j-1
   jh=j
   do j1=0,2
    j2=j+j1
    dvolh=ay1(j1)
    dvol(1)=vp(1)*dvolh
    do i1=0,1
     i2=ih+i1
     curr(i2,j2,k2,1)=curr(i2,j2,k2,1)+dvol(1)*axh1(i1)
    end do
   end do
   do j1=0,1
    j2=jh+j1
    dvolh=ayh1(j1)
    dvol(2)=vp(2)*dvolh
    do i1=0,2
     i2=i+i1
     curr(i2,j2,k2,2)=curr(i2,j2,k2,2)+dvol(2)*ax1(i1)
    end do
   end do
  end do
 case(3)
  if(s_ind==0)then
   do n=1,np
    xp1(2:3)=part(2:3,n)                !new y-z positions
    part(2,n)=dy_inv*(xp1(2)-ymn)
    part(3,n)=dz_inv*(xp1(3)-zmn)
   end do
  else
   call map3d_part_sind(part,np,s_ind,2,3,ymn,zmn)
  endif
  do n=1,np
   xp1(1:3)=part(1:3,n)               !positions at current time t^{i-1}
   vp(1:3)=part(4:6,n)                !wgh*dt_rk*velocities at current time

   ax=shx+dx_inv*(xp1(1)-xmn)
   i=int(ax+0.5)
   sx=ax-real(i,dp)
   sx2=sx*sx
   ax1(1)=0.75-sx2
   ax1(2)=0.5*(0.25+sx2+sx)
   ax1(0)=1.-ax1(1)-ax1(2)
   axh1(1)=sx+0.5
   axh1(0)=1.-axh1(1)
   !=========
   ax=shy+xp1(2)
   j=int(ax+0.5)
   sx=ax-real(j,dp)
   sx2=sx*sx
   ay1(1)=0.75-sx2
   ay1(2)=0.5*(0.25+sx2+sx)
   ay1(0)=1.-ay1(1)-ay1(2)
   ayh1(1)=sx+0.5
   ayh1(0)=1.-ayh1(1)

   ax=shz+xp1(3)
   k=int(ax+0.5)
   sx=ax-real(k,dp)
   sx2=sx*sx
   az1(1)=0.75-sx2
   az1(2)=0.5*(0.25+sx2+sx)
   az1(0)=1.-az1(1)-az1(2)

   azh1(1)=sx+0.5
   azh1(0)=1.-azh1(1)
   i=i-1
   j=j-1
   k=k-1
   ih=i
   jh=j
   kh=k
   do k1=0,2
    k2=k+k1
    do j1=0,2
     j2=j+j1
     dvolh=ay1(j1)*az1(k1)
     dvol(1)=vp(1)*dvolh
     do i1=0,1
      i2=ih+i1
      curr(i2,j2,k2,1)=curr(i2,j2,k2,1)+dvol(1)*axh1(i1)
     end do
    end do
    do j1=0,1
     j2=jh+j1
     dvolh=ayh1(j1)*az1(k1)
     dvol(2)=vp(2)*dvolh
     do i1=0,2
      i2=i+i1
      curr(i2,j2,k2,2)=curr(i2,j2,k2,2)+dvol(2)*ax1(i1)
     end do
    end do
   end do
   do k1=0,1
    k2=kh+k1
    do j1=0,2
     j2=j+j1
     dvolh=ay1(j1)*azh1(k1)
     dvol(3)=vp(3)*dvolh
     do i1=0,2
      i2=i+i1
      curr(i2,j2,k2,3)=curr(i2,j2,k2,3)+dvol(3)*ax1(i1)
     end do
    end do
   end do
  end do
 end select
 end subroutine ncdef_rk_curr
 !====================
 end module particles
 !==========================
