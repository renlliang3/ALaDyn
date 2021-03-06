!*****************************************************************************************************!
!                            Copyright 2008-2020  The ALaDyn Collaboration                            !
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

 module grid_part_connect

  use pstruct_data
  use fstruct_data
  use grid_part_lib

  implicit none
  !========= SECTION FOR FIELDS ASSIGNEMENT
 contains

  !==========================================
  subroutine set_part1d_acc(ef, sp_loc, pt, np, ndf)

   real (dp), intent (in) :: ef(:, :, :, :)
   type (species), intent (in) :: sp_loc
   real (dp), intent (inout) :: pt(:, :)
   integer, intent (in) :: np, ndf

   real (dp) :: xp1(3), ap(6)
   real (dp) :: axh(0:2), ax1(0:2)
   integer :: i, ih, i1, i2, j2, n
   !=====================
   !================================
   select case (ndf)
   case (3)
    j2 = 1
    do n = 1, np
     ap(1:3) = zero_dp
     xp1(1) = sp_loc%part(n, 1) !the current particle positions

     call qqh_1d_spline(xp1, ax1, axh, i, ih)

     do i1 = 0, 2
      i2 = i1 + ih
      ap(1) = ap(1) + axh(i1)*ef(i2, j2, 1, 1) !Ex(i+1/2)
      ap(3) = ap(3) + axh(i1)*ef(i2, j2, 1, 3) !Bz(i+1/2)
      i2 = i + i1
      ap(2) = ap(2) + ax1(i1)*ef(i2, j2, 1, 2) !Ey(i)
     end do
     pt(n, 1:3) = ap(1:3)
    end do
   !========================
   case (6)
    j2 = 1
    do n = 1, np
     ap(1:6) = zero_dp
     xp1(1) = sp_loc%part(n, 1) !the current particle positions

     call qqh_1d_spline(xp1, ax1, axh, i, ih)

     do i1 = 0, 2
      i2 = i1 + ih
      ap(1) = ap(1) + axh(i1)*ef(i2, j2, 1, 1) !Ex
      ap(5) = ap(5) + axh(i1)*ef(i2, j2, 1, 5) !By
      ap(6) = ap(6) + axh(i1)*ef(i2, j2, 1, 6) !Bz
     end do
     do i1 = 0, 2
      i2 = i + i1
      ap(2) = ap(2) + ax1(i1)*ef(i2, j2, 1, 2) !Ey
      ap(3) = ap(3) + ax1(i1)*ef(i2, j2, 1, 3) !Ez
      ap(4) = ap(4) + ax1(i1)*ef(i2, j2, 1, 4) !Bx
     end do
     pt(n, 1:6) = ap(1:6)
    end do
   end select
  end subroutine
  !===========================
  subroutine set_part2d_hcell_acc(ef, sp_loc, pt, np, ndf)

   real (dp), intent (in) :: ef(:, :, :, :)
   type (species), intent (in) :: sp_loc
   real (dp), intent (inout) :: pt(:, :)
   integer, intent (in) :: np, ndf

   real (dp) :: dvol, dvol1
   real (dp) :: xp1(3), ap(6)
   real (dp) :: axh(0:1), ax1(0:2)
   real (dp) :: ayh(0:1), ay1(0:2)

   integer :: i, ih, j, jh, i1, j1, i2, j2, n
   !================================
   ! Uses quadratic or linear shapes depending on staggering
   ! ndf is the number of field component
   xp1 = zero_dp
   do n = 1, np
    pt(n, 1:3) = sp_loc%part(n, 1:3)
   end do
   call set_local_2d_positions(pt, 1, np)

   select case (ndf) !Field components
   case (3)
    do n = 1, np
     ap(1:3) = zero_dp
     xp1(1:2) = pt(n, 1:2)
     call qlh_2d_spline(xp1, ax1, axh, ay1, ayh, i, ih, j, jh)

     do j1 = 0, 2
      j2 = j + j1
      dvol = ay1(j1)
      do i1 = 0, 1
       i2 = i1 + ih
       dvol1 = axh(i1)*dvol
       ap(1) = ap(1) + dvol1*ef(i2, j2, 1, 1) !Ex(i+1/2,j)
      end do
     end do
     do j1 = 0, 1
      j2 = jh + j1
      dvol = ayh(j1)
      do i1 = 0, 2
       i2 = i + i1
       dvol1 = ax1(i1)*dvol
       ap(2) = ap(2) + dvol1*ef(i2, j2, 1, 2) !Ey(i,j+1/2)
      end do
      do i1 = 0, 1
       i2 = i1 + ih
       dvol1 = axh(i1)*dvol
       ap(3) = ap(3) + dvol1*ef(i2, j2, 1, 3) !Bz(i+1/2,j+1/2)
      end do
     end do
     pt(n, 1:3) = ap(1:3)
    end do
    !==============
   case (6)
    !=====================
    do n = 1, np
     ap(1:6) = zero_dp
     xp1(1:2) = pt(n, 1:2)
     call qlh_2d_spline(xp1, ax1, axh, ay1, ayh, i, ih, j, jh)

     do j1 = 0, 2
      j2 = j + j1
      dvol = ay1(j1)
      do i1 = 0, 1
       i2 = i1 + ih
       dvol1 = axh(i1)*dvol
       ap(1) = ap(1) + dvol1*ef(i2, j2, 1, 1) !Ex(i+1/2,j)
       ap(5) = ap(5) + dvol1*ef(i2, j2, 1, 5) !By(i+1/2,j)
      end do
      do i1 = 0, 2
       i2 = i1 + i
       dvol1 = ax1(i1)*dvol
       ap(3) = ap(3) + dvol1*ef(i2, j2, 1, 3) !Ez(i,j,k+1/2)
      end do
     end do
     do j1 = 0, 1
      j2 = jh + j1
      dvol = ayh(j1)
      do i1 = 0, 2
       i2 = i + i1
       dvol1 = ax1(i1)*dvol
       ap(2) = ap(2) + dvol1*ef(i2, j2, 1, 2) !Ey(i,j+1/2)
       ap(4) = ap(4) + dvol1*ef(i2, j2, 1, 4) !Bx(i,j+1/2)
      end do
      do i1 = 0, 1
       i2 = i1 + ih
       dvol1 = axh(i1)*dvol
       ap(6) = ap(6) + dvol1*ef(i2, j2, 1, 6) !Bz(i+1/2,j+1/2)
      end do
     end do
     pt(n, 1:6) = ap(1:6)
    end do
   end select
   !=====================
  end subroutine
  !====================================
  subroutine set_part3d_hcell_acc(ef, sp_loc, pt, np)

   real (dp), intent (in) :: ef(:, :, :, :)
   type (species), intent (in) :: sp_loc
   real (dp), intent (inout) :: pt(:, :)
   integer, intent (in) :: np

   real (dp) :: dvol, ap(6), xp1(3)
   real (dp) :: axh(0:1), ax1(0:2)
   real (dp) :: ayh(0:1), ay1(0:2)
   real (dp) :: azh(0:1), az1(0:2)
   integer :: i, ih, j, jh, i1, j1, i2, j2, k, kh, k1, k2, n

   !===============================================
   !Staggered shapes
   ! Linear shape at half-index
   ! Quadratic shape at integer index
   !====================================
   !=============================================================
   do n = 1, np
    pt(n, 1:3) = sp_loc%part(n, 1:3)
   end do
   call set_local_3d_positions(pt, 1, np)
   !==========================
   do n = 1, np
    ap(1:6) = zero_dp
    xp1(1:3) = pt(n, 1:3)

    call qlh_3d_spline(xp1, ax1, axh, ay1, ayh, az1, azh, i, ih, j, jh, &
      k, kh)

    ! Ex(i+1/2,j,k)
    !==============
    !==============
    ! Ey(i,j+1/2,k)
    !==============
    !==============
    ! Bz(i+1/2,j+1/2,k)
    !==============
    do k1 = 0, 2
     k2 = k + k1
     do j1 = 0, 2
      j2 = j + j1
      dvol = ay1(j1)*az1(k1)
      do i1 = 0, 1
       i2 = i1 + ih
       ap(1) = ap(1) + axh(i1)*dvol*ef(i2, j2, k2, 1)
      end do
     end do
     do j1 = 0, 1
      j2 = jh + j1
      dvol = ayh(j1)*az1(k1)
      do i1 = 0, 2
       i2 = i + i1
       ap(2) = ap(2) + ax1(i1)*dvol*ef(i2, j2, k2, 2)
      end do
      do i1 = 0, 1
       i2 = i1 + ih
       ap(6) = ap(6) + axh(i1)*dvol*ef(i2, j2, k2, 6)
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

    do k1 = 0, 1
     k2 = kh + k1
     do j1 = 0, 1
      j2 = jh + j1
      dvol = ayh(j1)*azh(k1)
      do i1 = 0, 2
       i2 = i1 + i
       ap(4) = ap(4) + ax1(i1)*dvol*ef(i2, j2, k2, 4)
      end do
     end do
     do j1 = 0, 2
      j2 = j + j1
      dvol = ay1(j1)*azh(k1)
      do i1 = 0, 1
       i2 = ih + i1
       ap(5) = ap(5) + axh(i1)*dvol*ef(i2, j2, k2, 5)
      end do
      do i1 = 0, 2
       i2 = i1 + i
       ap(3) = ap(3) + ax1(i1)*dvol*ef(i2, j2, k2, 3)
      end do
     end do
    end do
    pt(n, 1:6) = ap(1:6)
   end do

  end subroutine
  !======================================

  subroutine set_ion_efield(ef, sp_loc, pt, np)

   real (dp), intent (in) :: ef(:, :, :, :)
   type (species), intent (in) :: sp_loc
   real (dp), intent (inout) :: pt(:, :)
   integer, intent (in) :: np

   real (dp) :: ef_sqr, dvol, ex, ey, ez
   real (dp) :: axh(0:2), ax1(0:2)
   real (dp) :: ayh(0:2), ay1(0:2)
   real (dp) :: azh(0:2), az1(0:2)
   real (dp) :: xp1(3)
   integer :: i, ih, j, jh, k, kh
   integer :: n, ip1, jp1, kp1, ip2, jp2, kp2

   !===============================================
   ! qlh_spline()      Linear shape at half-index quadratic shape at integer index
   ! qqh_spline()      quadratic shape at half-index and at integer index
   !                 For field assignements
   !====================================
   ! fields are at t^n
   select case (ndim)
   case (2)
    kp2 = 1
    do n = 1, np
     pt(n, 1:2) = sp_loc%part(n, 1:2)
    end do
    call set_local_2d_positions(pt, 1, np)
    !==========================
    do n = 1, np
     ef_sqr = zero_dp
     xp1(1:2) = pt(n, 1:2)

     call qqh_2d_spline(xp1, ax1, axh, ay1, ayh, i, ih, j, jh)

     ! Ex(i+1/2,j,k)
     !==============
     !==============
     ! Ey(i,j+1/2,k)
     !==============
     do jp1 = 0, 2
      jp2 = j + jp1
      dvol = ay1(jp1)
      do ip1 = 0, 2
       ip2 = ih + ip1
       ex = ef(ip2, jp2, kp2, 1)
       ef_sqr = ef_sqr + axh(ip1)*dvol*ex*ex
      end do
     end do
     do jp1 = 0, 2
      jp2 = jh + jp1
      dvol = ayh(jp1)
      do ip1 = 0, 2
       ip2 = i + ip1
       ey = ef(ip2, jp2, kp2, 2)
       ef_sqr = ef_sqr + ax1(ip1)*dvol*ey*ey
      end do
     end do
     !==============
     pt(n, 5) = ef_sqr !Ex(p)^2 + Ey(p)^2
    end do
    !=======================================

   case (3)
    do n = 1, np
     pt(n, 1:3) = sp_loc%part(n, 1:3)
    end do
    call set_local_3d_positions(pt, 1, np)
    !==========================
    ! Here Quadratic shapes are used
    do n = 1, np
     ef_sqr = zero_dp
     xp1(1:3) = pt(n, 1:3)

     call qqh_3d_spline(xp1, ax1, axh, ay1, ayh, az1, azh, i, ih, j, jh, &
       k, kh)

     ! Ex(i+1/2,j,k)
     !==============
     !==============
     ! Ey(i,j+1/2,k)
     !==============
     do kp1 = 0, 2
      kp2 = k + kp1
      do jp1 = 0, 2
       jp2 = j + jp1
       dvol = ay1(jp1)*az1(kp1)
       do ip1 = 0, 2
        ip2 = ip1 + ih
        ex = ef(ip2, jp2, kp2, 1)
        ef_sqr = ef_sqr + axh(ip1)*dvol*ex*ex
       end do
      end do
      do jp1 = 0, 2
       jp2 = jh + jp1
       dvol = ayh(jp1)*az1(kp1)
       do ip1 = 0, 2
        ip2 = i + ip1
        ey = ef(ip2, jp2, kp2, 2)
        ef_sqr = ef_sqr + ax1(ip1)*dvol*ey*ey
       end do
      end do
     end do
     !==============
     ! Ez(i,j,k+1/2)
     !==============
     do kp1 = 0, 2
      kp2 = kh + kp1
      do jp1 = 0, 2
       jp2 = j + jp1
       dvol = ay1(jp1)*azh(kp1)
       do ip1 = 0, 2
        ip2 = ip1 + i
        ez = ef(ip2, jp2, kp2, 3)
        ef_sqr = ef_sqr + ax1(ip1)*dvol*ez*ez
       end do
      end do
     end do
     pt(n, 7) = ef_sqr
    end do
   end select
   !================================
  end subroutine
  !===================================
  ! ENV field assignement section
  !===========================
  subroutine set_env_acc(ef, av, sp_loc, pt, np, dt_step)

   real (dp), intent (in) :: ef(:, :, :, :), av(:, :, :, :)
   type (species), intent (in) :: sp_loc
   real (dp), intent (inout) :: pt(:, :)
   integer, intent (in) :: np
   real (dp), intent (in) :: dt_step

   real (dp) :: dvol, dvol1
   real (dp) :: xp1(3), upart(3), ap(12)
   real (dp) :: aa1, b1, dgam, gam_inv, gam, gam2, dth
   real (dp) :: axh1(0:2), ax1(0:2)
   real (dp) :: ayh1(0:2), ay1(0:2)
   real (dp) :: azh1(0:2), az1(0:2)
   integer :: i, ih, j, jh, i2, j2, k, kh, k2, n
   integer (kind=2) :: i1, j1, k1
   integer (kind=2), parameter :: stl = 2
   !===============================================
   !===============================================
   ! Uses quadratic shape functions at integer and half-integer grid points
   !====================================
   !===================================================
   ! enter ef(1:6) wake fields
   ! enters av(1)=F=|a|^2/2 envelope at integer grid nodes
   ! and av(2:4)=grad[F] at staggered points
   !  COMPUTES
   !(E,B), F, grad[F] assignements to particle positions 
   ! => ap(1:6)  in 2D 
   ! => ap(1:10) in 3D
   ! approximated gamma function:
   ! gam_new= gam +0.25*charge*Dt(gam*E+0.5*grad[F]).p^{n-1/2}/gam^2
   ! EXIT
   ! (E+ 0.5grad[F]/gam_new) B/gam_new, F   and wgh/gam_new  
   ! pt(1:5)  in 2D
   ! pt(1:7)  in 3D
   !========================================
   dth = 0.5*dt_step
   select case (ndim)
   !==========================
   case (2)
    ax1(0:2) = zero_dp
    ay1(0:2) = zero_dp
    axh1(0:2) = zero_dp
    ayh1(0:2) = zero_dp
    k2 = 1
    do n = 1, np
     pt(n, 1:2) = sp_loc%part(n, 1:2)
    end do
    call set_local_2d_positions(pt, 1, np)
    do n = 1, np
     ap(1:6) = 0.0
     xp1(1:2) = pt(n, 1:2) !the current particle positions
     upart(1:2) = sp_loc%part(n, 3:4) !the current particle  momenta
     wgh_cmp = sp_loc%part(n, 5) !the current particle (weight,charge)

     call qqh_2d_spline(xp1, ax1, axh1, ay1, ayh1, i, ih, j, jh)
     !==========================
     do j1 = 0, stl
      j2 = j + j1
      dvol = ay1(j1)
      do i1 = 0, stl
       i2 = i + i1
       ap(6) = ap(6) + ax1(i1)*dvol*av(i2, j2, k2, 1) !t^n p-assigned F=a^2/2 field
      end do
      do i1 = 0, stl
       i2 = ih + i1
       dvol1 = dvol*axh1(i1)
       ap(1) = ap(1) + dvol1*ef(i2, j2, k2, 1) !Ex and Dx[F] (i+1/2,j,k))
       ap(4) = ap(4) + dvol1*av(i2, j2, k2, 2)
       !ap(4)=ap(4)+dvol1*dx_inv*(av(i2+1,j2,k2,1)-av(i2,j2,k2,1))
      end do
     end do
     do j1 = 0, stl
      j2 = jh + j1
      dvol = ayh1(j1)
      do i1 = 0, stl
       i2 = i + i1
       dvol1 = dvol*ax1(i1)
       ap(2) = ap(2) + dvol1*ef(i2, j2, k2, 2) !Ey and Dy[F] (i,j+1/2,k)
       ap(5) = ap(5) + dvol1*av(i2, j2, k2, 3)
       !ap(5)=ap(5)+dvol1*dy_inv*(av(i2,j2+1,k2,1)-av(i2,j2,k2,1))
      end do
      do i1 = 0, stl
       i2 = ih + i1
       ap(3) = ap(3) + axh1(i1)*dvol*ef(i2, j2, k2, 3) !Bz(i+1/2,j+1/2,k)
      end do
     end do
     !=========================
     gam2 = 1. + upart(1)*upart(1) + upart(2)*upart(2) + ap(6) !gamma^{n-1/2}
     ap(1:3) = charge*ap(1:3)
     ap(4:5) = 0.5*charge*charge*ap(4:5)
     !  ap(1:2)=q(Ex,Ey)   ap(3)=q*Bz,ap(4:5)=q*q*[Dx,Dy]F/2
     aa1 = dth*dot_product(ap(1:2), upart(1:2)) !Dt*(qE_ip_i)/2 ==> a
     b1 = dth*dot_product(ap(4:5), upart(1:2)) !Dt*(qD_iFp_i)/4 ===> c
     gam = sqrt(gam2)
     dgam = (aa1*gam-b1)/gam2
     gam_inv = (gam-dgam)/gam2
     ap(3:5) = ap(3:5)*gam_inv !ap(3)=q*B/gamp, ap(4:5)= q*Grad[F]/2*gamp

     pt(n, 1:2) = ap(1:2) - ap(4:5) ! Lorentz force already multiplied by q    
     pt(n, 3) = ap(3)
     pt(n, 5) = wgh*gam_inv !weight/gamp
    end do
    !=============================
   case (3)
    ax1(0:2) = zero_dp
    ay1(0:2) = zero_dp
    az1(0:2) = zero_dp
    azh1(0:2) = zero_dp
    axh1(0:2) = zero_dp
    ayh1(0:2) = zero_dp
    do n = 1, np
     pt(n, 1:3) = sp_loc%part(n, 1:3)
    end do
    call set_local_3d_positions(pt, 1, np)
    do n = 1, np
     ap = zero_dp
     xp1(1:3) = pt(n, 1:3)
     upart(1:3) = sp_loc%part(n, 4:6) !the current particle  momenta
     wgh_cmp = sp_loc%part(n, 7) !the current particle (weight,charge)

     call qqh_3d_spline(xp1, ax1, axh1, ay1, ayh1, az1, azh1, i, ih, j, &
       jh, k, kh)

     !==========================
     do k1 = 0, stl
      k2 = k + k1
      do j1 = 0, stl
       j2 = j + j1
       dvol = ay1(j1)*az1(k1)
       do i1 = 0, stl
        i2 = i1 + i
        ap(10) = ap(10) + ax1(i1)*dvol*av(i2, j2, k2, 1) !t^n p-assigned Phi=a^2/2 field
       end do
       do i1 = 0, stl
        i2 = i1 + ih
        dvol1 = dvol*axh1(i1)
        ap(1) = ap(1) + dvol1*ef(i2, j2, k2, 1) !Ex and Dx[F] (i+1/2,j,k))
        ap(7) = ap(7) + dvol1*av(i2, j2, k2, 2)
       end do
      end do
      do j1 = 0, stl
       j2 = jh + j1
       dvol = ayh1(j1)*az1(k1)
       do i1 = 0, 2
        i2 = i + i1
        dvol1 = dvol*ax1(i1)
        ap(2) = ap(2) + dvol1*ef(i2, j2, k2, 2) !Ey and Dy[F] (i,j+1/2,k)
        ap(8) = ap(8) + dvol1*av(i2, j2, k2, 3)
       end do
       do i1 = 0, stl
        i2 = i1 + ih
        ap(6) = ap(6) + axh1(i1)*dvol*ef(i2, j2, k2, 6) !Bz(i+1/2,j+1/2,k)
       end do
      end do
     end do
     !=========================
     do k1 = 0, stl
      k2 = kh + k1
      do j1 = 0, stl
       j2 = jh + j1
       dvol = ayh1(j1)*azh1(k1)
       do i1 = 0, stl
        i2 = i1 + i
        ap(4) = ap(4) + ax1(i1)*dvol*ef(i2, j2, k2, 4) !Bx(i,j+1/2,k+1/2)
       end do
      end do
      do j1 = 0, stl
       j2 = j + j1
       dvol = ay1(j1)*azh1(k1)
       do i1 = 0, stl
        i2 = ih + i1
        ap(5) = ap(5) + axh1(i1)*dvol*ef(i2, j2, k2, 5) !By(i+1/2,j,k+1/2)
       end do
       do i1 = 0, stl
        i2 = i1 + i
        dvol1 = dvol*ax1(i1)
        ap(3) = ap(3) + dvol1*ef(i2, j2, k2, 3) !Ez and Dz[F] (i,j,k+1/2)
        ap(9) = ap(9) + dvol1*av(i2, j2, k2, 4)
       end do
      end do
     end do
     !=================================
     gam2 = 1. + upart(1)*upart(1) + upart(2)*upart(2) + &
      upart(3)*upart(3) + ap(10) !gamma^{n-1/2}
     ap(1:6) = charge*ap(1:6)
     ap(7:9) = 0.5*charge*charge*ap(7:9)
     !  ap(1:3)=q(Ex,Ey,Ez)   ap(4:6)=q(Bx,By,Bz),ap(7:9)=q[Dx,Dy,Dz]F/2
     aa1 = dth*dot_product(ap(1:3), upart(1:3))
     b1 = dth*dot_product(ap(7:9), upart(1:3))
     gam = sqrt(gam2)
     dgam = (aa1*gam-b1)/gam2
     gam_inv = (gam-dgam)/gam2

     ap(4:9) = ap(4:9)*gam_inv !ap(4:6)=B/gamp, ap(7:9)= Grad[F]/2*gamp

     pt(n, 1:3) = ap(1:3) - ap(7:9)
     pt(n, 4:6) = ap(4:6)
     pt(n, 7) = wgh*gam_inv !weight/gamp
    end do
   end select
  end subroutine
  !=======================================
  subroutine set_ion_env_field(ef, sp_loc, pt, np, om0)

   real (dp), intent (in) :: ef(:, :, :, :)
   type (species), intent (in) :: sp_loc
   real (dp), intent (inout) :: pt(:, :)
   integer, intent (in) :: np
   real (dp), intent (in) :: om0

   real (dp) :: axh1(0:2), ax1(0:2)
   real (dp) :: ayh1(0:2), ay1(0:2)
   real (dp) :: azh1(0:2), az1(0:2)
   real (dp) :: dvol, ddx, ddy
   real (dp) :: xp1(3), ap(6)
   integer :: i, ih, j, jh, i1, j1, i2, j2, k, kh, k1, k2, n
   !==============================
   ! Enter ef(1:2)<=  A=(A_R,A_I)
   ! Exit pt=|E|^2= |E_y|^2 + |E_x|^2 assigned to each ion particle
   !===========================
   !  Up to O(epsilon)^2:
   ! |E_y|^2= k_0^2*|A|^2+2*k_0*[A_R*Dx(A_I)-A_I*Dx(A_R)] +(Dx[A_R])^2 +Dx[A_I}^2)
   ! |E_x|^2= (Dy[A_R])^2 +Dy[A_I]^2)
   !===============================================
   !===============================================
   ! Quadratic shape functions
   !====================================
   ddx = dx_inv
   ddy = dy_inv
   !===== enter species positions at t^{n+1} level========
   ! fields are at t^n
   select case (ndim)
   case (2)
    ax1(0:2) = zero_dp
    ay1(0:2) = zero_dp
    axh1(0:2) = zero_dp
    ayh1(0:2) = zero_dp
    k2 = 1
    do n = 1, np
     pt(n, 1:2) = sp_loc%part(n, 1:2)
    end do
    call set_local_2d_positions(pt, 1, np)
    !==========================
    do n = 1, np
     ap(1:6) = zero_dp
     xp1(1:2) = pt(n, 1:2)

     call qqh_2d_spline(xp1, ax1, axh1, ay1, ayh1, i, ih, j, jh)

     do j1 = 0, 2
      j2 = j + j1
      dvol = ay1(j1)
      do i1 = 0, 2
       i2 = i1 + i
       ap(1) = ap(1) + ax1(i1)*dvol*ef(i2, j2, k2, 1) !A_R
       ap(2) = ap(2) + ax1(i1)*dvol*ef(i2, j2, k2, 2) !A_I
      end do
      do i1 = 0, 2
       i2 = i1 + ih
       ap(3) = ap(3) + axh1(i1)*dvol*(ef(i2+1,j2,k2,1)-ef(i2,j2,k2,1)) !DxA_R
       ap(4) = ap(4) + axh1(i1)*dvol*(ef(i2+1,j2,k2,2)-ef(i2,j2,k2,2)) !DxA_I
      end do
     end do
     do j1 = 0, 2
      j2 = jh + j1
      dvol = ayh1(j1)
      do i1 = 0, 2
       i2 = i + i1
       ap(5) = ap(5) + ax1(i1)*dvol*(ef(i2,j2+1,k2,1)-ef(i2,j2,k2,1)) !DyA_R
       ap(6) = ap(6) + ax1(i1)*dvol*(ef(i2,j2+1,k2,2)-ef(i2,j2,k2,2)) !DyA_I
      end do
     end do
     !==================
     pt(n, 4) = sqrt(ap(1)*ap(1)+ap(2)*ap(2)) !The interpolated |A| potential
     ap(1) = om0*ap(1)
     ap(2) = om0*ap(2)
     ap(3) = ddx*ap(3)
     ap(4) = ddx*ap(4)
     ap(5) = ddy*ap(5)
     ap(6) = ddy*ap(6)
     pt(n, 5) = ap(1)*ap(1) + ap(2)*ap(2) + ap(3)*ap(3) + ap(4)*ap(4) + &
       ap(5)*ap(5) + ap(6)*ap(6)
     pt(n, 5) = pt(n, 5) + 2.*(ap(1)*ap(4)-ap(2)*ap(3))
    end do
    !==========================
   case (3)
    ax1(0:2) = zero_dp
    ay1(0:2) = zero_dp
    axh1(0:2) = zero_dp
    ayh1(0:2) = zero_dp
    az1(0:2) = zero_dp
    azh1(0:2) = zero_dp

    do n = 1, np
     pt(n, 1:3) = sp_loc%part(n, 1:3)
    end do
    call set_local_3d_positions(pt, 1, np)
    do n = 1, np
     ap(1:6) = zero_dp
     xp1(1:3) = pt(n, 1:3)

     call qqh_3d_spline(xp1, ax1, axh1, ay1, ayh1, az1, azh1, i, ih, j, &
       jh, k, kh)
     !=============== Quadratic/linear assignements
     do k1 = 0, 2
      k2 = k + k1
      do j1 = 0, 2
       j2 = j + j1
       dvol = ay1(j1)*az1(k1)
       do i1 = 0, 2
        i2 = i1 + i
        ap(1) = ap(1) + ax1(i1)*dvol*ef(i2, j2, k2, 1) !A_R
        ap(2) = ap(2) + ax1(i1)*dvol*ef(i2, j2, k2, 2) !A_I
       end do
       do i1 = 0, 2
        i2 = i1 + ih
        ap(3) = ap(3) + axh1(i1)*dvol*(ef(i2+1,j2,k2,1)-ef(i2,j2,k2,1)) !DxA_R
        ap(4) = ap(4) + axh1(i1)*dvol*(ef(i2+1,j2,k2,2)-ef(i2,j2,k2,2)) !DxA_I
       end do
      end do
      do j1 = 0, 2
       j2 = jh + j1
       dvol = ayh1(j1)*az1(k1)
       do i1 = 0, 2
        i2 = i + i1
        ap(5) = ap(5) + ax1(i1)*dvol*(ef(i2,j2+1,k2,1)-ef(i2,j2,k2,1)) !DyA_R
        ap(6) = ap(6) + ax1(i1)*dvol*(ef(i2,j2+1,k2,2)-ef(i2,j2,k2,2)) !DyA_I
       end do
      end do
     end do
     pt(n, 6) = sqrt(ap(1)*ap(1)+ap(2)*ap(2)) !The interpolated |A| potential
     ap(1) = om0*ap(1)
     ap(2) = om0*ap(2)
     ap(3) = ddx*ap(3)
     ap(4) = ddx*ap(4)
     ap(5) = ddy*ap(5)
     ap(6) = ddy*ap(6)
     pt(n, 7) = ap(1)*ap(1) + ap(2)*ap(2) + ap(3)*ap(3) + ap(4)*ap(4) + &
       ap(5)*ap(5) + ap(6)*ap(6)
     pt(n, 7) = pt(n, 7) + 2.*(ap(1)*ap(4)-ap(2)*ap(3))
    end do
   end select
   !================================
  end subroutine
  !================================
  subroutine set_env_grad_interp(av, sp_loc, pt, np, ndm)

   type (species), intent (in) :: sp_loc
   real (dp), intent (in) :: av(:, :, :, :)
   real (dp), intent (inout) :: pt(:, :)
   integer, intent (in) :: np, ndm

   real (dp) :: axh1(0:2), ax1(0:2)
   real (dp) :: ayh1(0:2), ay1(0:2)
   real (dp) :: azh1(0:2), az1(0:2)
   real (dp) :: dvol, dvol1, dxe, dye, dze
   real (dp) :: xp1(3), ap(4)
   integer :: i, ih, j, jh, i1, j1, i2, j2, k, kh, k1, k2, n

   !===============================================
   ! enters av(1)=|a|^2/2 envelope at integer grid nodes
   ! and av(2:4)=[Grad |a|2/2] at staggered grid points
   ! exit in pt(1:4) grad[|a|^2]/2 and |a|^2/2 at the particle positions
   ! On output => Reverse ordering of field variables is used
   !=========================
   ! Particle positions assigned using quadratic splines
   !  F=|a|^2/2
   !  ap(1)= [D_x(F)](i+1/2,j,k)
   !  ap(2)= [D_y(F)](i,j+1/2,k)
   !  ap(3)= [D_z(F)](i,j,k+1/2)
   !  ap(4)= [Phi](i,j,k)
   !===========================================

   select case (ndim)
   case (2)
    dxe = dx_inv
    dye = dy_inv
    k2 = 1
    do n = 1, np
     pt(n, 1:2) = sp_loc%part(n, 1:2) !
    end do
    call set_local_2d_positions(pt, 1, np)
    do n = 1, np
     ap = 0.0
     xp1(1:2) = pt(n, 1:2)

     call qqh_2d_spline(xp1, ax1, axh1, ay1, ayh1, i, ih, j, jh)
     !==========================
     do j1 = 0, 2
      j2 = j + j1
      dvol = ay1(j1)
      do i1 = 0, 2
       i2 = i1 + ih
       dvol1 = dvol*axh1(i1)
       ap(1) = ap(1) + dvol1*av(i2, j2, k2, 2) !Dx[Phi]
       i2 = i1 + i
       ap(3) = ap(3) + ax1(i1)*dvol*av(i2, j2, k2, 1) ![Phi]
      end do
     end do
     do j1 = 0, 2
      j2 = jh + j1
      dvol = ayh1(j1)
      do i1 = 0, 2
       i2 = i + i1
       dvol1 = dvol*ax1(i1)
       ap(2) = ap(2) + dvol1*av(i2, j2, k2, 3) !Dy[Phi]
      end do
     end do
     !pt(n,1)=dxe*ap(1)    !assigned grad[A^2/2]
     !pt(n,2)=dye*ap(2)
     pt(n, 1:3) = ap(1:3) !assigned grad[Phi] and Phi
    end do
    !=================================
   case (3)
    dxe = dx_inv
    dye = dy_inv
    dze = dz_inv
    do n = 1, np
     pt(n, 1:3) = sp_loc%part(n, 1:3)
    end do
    call set_local_3d_positions(pt, 1, np)
    do n = 1, np
     ap = 0.0
     xp1(1:3) = pt(n, 1:3)

     call qqh_3d_spline(xp1, ax1, axh1, ay1, ayh1, az1, azh1, i, ih, j, &
       jh, k, kh)

     !==========================
     ap = 0.0
     do k1 = 0, 2
      k2 = k + k1
      do j1 = 0, 2
       j2 = j + j1
       dvol = ay1(j1)*az1(k1)
       do i1 = 0, 2
        i2 = i1 + ih
        dvol1 = dvol*axh1(i1)
        ap(1) = ap(1) + dvol1*av(i2, j2, k2, 2) !Dx[F]
        i2 = i1 + i
        ap(4) = ap(4) + ax1(i1)*dvol*av(i2, j2, k2, 1) !Phi
       end do
      end do
      do j1 = 0, 2
       j2 = jh + j1
       dvol = ayh1(j1)*az1(k1)
       do i1 = 0, 2
        i2 = i + i1
        dvol1 = dvol*ax1(i1)
        ap(2) = ap(2) + dvol1*av(i2, j2, k2, 3) !Dy[F]
       end do
      end do
      k2 = kh + k1
      do j1 = 0, 2
       j2 = j + j1
       dvol = ay1(j1)*azh1(k1)
       do i1 = 0, 2
        i2 = i + i1
        dvol1 = dvol*ax1(i1)
        ap(3) = ap(3) + dvol1*av(i2, j2, k2, 4) !Dz[F]
       end do
      end do
     end do
     pt(n, 1:4) = ap(1:4) !Exit grad[Phi] and Phi
     !=================================
    end do
   end select
  end subroutine
  !===========================
  subroutine set_env_density(efp, av, np, ic)

   real (dp), intent (inout) :: efp(:, :)
   real (dp), intent (inout) :: av(:, :, :, :)
   integer, intent (in) :: np, ic

   real (dp) :: dvol, dvol1, wghp
   real (dp) :: ax1(0:2), ay1(0:2), az1(0:2), xp1(3)
   integer :: i, j, i1, j1, i2, j2, k, k1, k2, n
   !===============================================
   ! 2D enter efp(1:2) positions and efp(5) wgh/gamp at time level n
   ! 3D enter efp(1:3) positions and efp(7) wgh/gamp at time level n
   ! exit av(:,:,:,ic) the den source in envelope equation :  <n*wgh/gamp> > 0
   ! exit efp(1:3) relative positions at time level n
   !=========================
   ax1(0:2) = zero_dp
   ay1(0:2) = zero_dp
   az1(0:2) = zero_dp

   select case (ndim)
   case (2)
    k2 = 1
    call set_local_2d_positions(efp, 1, np)
    do n = 1, np
     xp1(1:2) = efp(n, 1:2)
     wghp = efp(n, 5) !the particle  wgh/gamp at current time
     call qden_2d_wgh(xp1, ax1, ay1, i, j)
     i = i - 1
     j = j - 1
     !==========================
     do j1 = 0, 2
      j2 = j + j1
      dvol = ay1(j1)*wghp
      do i1 = 0, 2
       i2 = i1 + i
       dvol1 = dvol*ax1(i1)
       av(i2, j2, k2, ic) = av(i2, j2, k2, ic) + dvol1
      end do
     end do
    end do
    !========================
   case (3)
    call set_local_3d_positions(efp, 1, np)
    do n = 1, np
     xp1(1:3) = efp(n, 1:3) ! local x-y-z
     wghp = efp(n, 7) !the particle  wgh/gamp at current time
     call qden_3d_wgh(xp1, ax1, ay1, az1, i, j, k)
     i = i - 1
     j = j - 1
     k = k - 1

     do k1 = 0, 2
      k2 = k + k1
      do j1 = 0, 2
       j2 = j + j1
       dvol = ay1(j1)*az1(k1)*wghp
       do i1 = 0, 2
        i2 = i1 + i
        dvol1 = dvol*ax1(i1)
        av(i2, j2, k2, ic) = av(i2, j2, k2, ic) + dvol1
       end do
      end do
     end do
    end do
   end select
   !In ebfp(1:3) exit relative (x,y,z) positions at current t^n level
   !In av(ic)  exit particle density
   !================================
  end subroutine
  !====================================================
  !========= PARTICLE ASSIGNEMENT TO GRID FOR CURRENT DENSITY
  !=============================
  subroutine esirkepov_2d_curr(sp_loc, pt, jcurr, np)

   type (species), intent (in) :: sp_loc
   real (dp), intent (inout) :: pt(:, :), jcurr(:, :, :, :)
   integer, intent (in) :: np
   real (dp) :: dvol
   real (dp) :: ax0(0:3), ay0(0:3), xp1(3), xp0(3)
   real (dp) :: ax1(0:3), ay1(0:3), vp(3)
   real (dp) :: axh(0:4), axh0(0:4), axh1(0:4), ayh(0:4)
   real (dp) :: currx(0:4), curry(0:4)
   real (sp) :: wght
   integer :: i, j, ii0, jj0, i1, j1, i2, j2, n
   integer :: ih, jh, x0, x1, y0, y1
   !==========================
   !Iform=0 or 1 IMPLEMENTS the ESIRKEPOV SCHEME for LINEAR-QUADRATIC SHAPE
   ! ==============================Only new and old positions needed
   ax1 = zero_dp
   ay1 = zero_dp
   ax0 = zero_dp
   ay0 = zero_dp
   !======================
   select case (ndim)
   case (2)
    if (curr_ndim==2) then !Two current components
     do n = 1, np
      pt(n, 1:2) = sp_loc%part(n, 1:2) !x-y-new  t^(n+1)
      wgh_cmp = sp_loc%part(n, 5)
      wght = charge*wgh
      pt(n, 5) = wght
     end do
     call set_local_2d_positions(pt, 2, np)
     !========================
     ii0 = 0
     jj0 = 0
     i = 0
     j = 0

     do n = 1, np
      xp1(1:2) = pt(n, 1:2) !x-y  -new
      xp0(1:2) = pt(n, 3:4) !x-y  -old
      wght = real(pt(n,5), sp) !w*q
      !=====================
      call qden_2d_wgh(xp0, ax0, ay0, ii0, jj0)
      call qden_2d_wgh(xp1, ax1, ay1, i, j)

      axh(0:4) = zero_dp
      ih = i - ii0 + 1
      do i1 = 0, 2
       axh(ih+i1) = ax1(i1)
      end do
      currx(0) = -axh(0)
      do i1 = 1, 3
       currx(i1) = currx(i1-1) + ax0(i1-1) - axh(i1)
      end do
      currx(4) = currx(3) - axh(4)
      do i1 = 1, 3
       axh(i1) = axh(i1) + ax0(i1-1)
      end do
      currx(0:4) = wght*currx(0:4)
      x0 = min(ih, 1)
      x1 = max(ih+2, 3)
      !-------
      jh = j - jj0 + 1
      ayh(0:4) = zero_dp
      do i1 = 0, 2
       ayh(jh+i1) = ay1(i1)
      end do
      curry(0) = -ayh(0)
      do i1 = 1, 3
       curry(i1) = curry(i1-1) + ay0(i1-1) - ayh(i1)
      end do
      curry(4) = curry(3) - ayh(4)
      curry(0:4) = wght*curry(0:4)
      !========================================
      do i1 = 1, 3
       ayh(i1) = ayh(i1) + ay0(i1-1)
      end do
      y0 = min(jh, 1)
      y1 = max(jh+2, 3)
      !================dt*J_x
      jj0 = jj0 - 1
      j = j - 1
      jh = jj0 - 1

      i = i - 1
      ii0 = ii0 - 1
      ih = ii0 - 1

      do j1 = y0, y1
       j2 = jh + j1
       do i1 = x0, x1
        i2 = ih + i1
        jcurr(i2, j2, 1, 1) = jcurr(i2, j2, 1, 1) + ayh(j1)*currx(i1)
       end do
      end do
      !================dt*J_y
      do j1 = y0, y1
       j2 = jh + j1
       do i1 = x0, x1
        i2 = ih + i1
        jcurr(i2, j2, 1, 2) = jcurr(i2, j2, 1, 2) + axh(i1)*curry(j1)
       end do
      end do
     end do
    end if
    if (curr_ndim==3) then !Three currents conditions in 2D grid
     do n = 1, np
      pt(n, 1:3) = sp_loc%part(n, 1:3) !x-y-z -new  t^(n+1)
      wgh_cmp = sp_loc%part(n, 7)
      wght = charge*wgh
      pt(n, 7) = wght
     end do
     call set_local_2d_positions(pt, 2, np)
     !==============================
     do n = 1, np
      xp1(1:3) = pt(n, 1:3) !increments xyz-new
      xp0(1:3) = pt(n, 4:6) !increments xyz z-old
      wght = real(pt(n,7), sp)
      vp(3) = xp1(3) - xp0(3) !dt*v_z(n+1/2)
      vp(3) = wght*vp(3)/3. !dt*q*w*vz/3
      !=====================
      call qden_2d_wgh(xp0, ax0, ay0, ii0, jj0)
      call qden_2d_wgh(xp1, ax1, ay1, i, j)

      axh(0:4) = zero_dp
      ih = i - ii0 + 1
      x0 = min(ih, 1)
      x1 = max(ih+2, 3)
      do i1 = 0, 2
       axh(ih+i1) = ax1(i1)
      end do
      currx(0) = -axh(0)
      do i1 = 1, 3
       currx(i1) = currx(i1-1) + ax0(i1-1) - axh(i1)
      end do
      currx(4) = currx(3) - axh(4)
      do i1 = 1, 3
       axh(i1) = axh(i1) + ax0(i1-1)
      end do
      currx(0:4) = wght*currx(0:4)

      axh0(0:4) = 0.5*axh(0:4)
      axh1(0:4) = axh(0:4)
      do i1 = 1, 3
       axh0(i1) = axh0(i1) + ax0(i1-1)
       axh1(i1) = axh1(i1) + 0.5*ax0(i1-1)
       axh(i1) = axh(i1) + ax0(i1-1) !Wx^0+Wx^1)
      end do
      !-------
      i = i - 1
      ii0 = ii0 - 1

      jh = j - jj0 + 1
      y0 = min(jh, 1)
      y1 = max(jh+2, 3)

      ayh(0:4) = zero_dp
      do i1 = 0, 2
       ayh(jh+i1) = ay1(i1)
      end do
      curry(0) = -ayh(0)
      do i1 = 1, 3
       curry(i1) = curry(i1-1) + ay0(i1-1) - ayh(i1)
      end do
      curry(4) = curry(3) - ayh(4)
      curry(0:4) = wght*curry(0:4)
      do i1 = 1, 3
       ayh(i1) = ayh(i1) + ay0(i1-1)
      end do
      !-----------
      jj0 = jj0 - 1
      j = j - 1
      !================dt*J_x= currx*(Wy^0+Wy^1) to be multiplied by dx/2
      ih = ii0 - 1
      jh = jj0 - 1
      do j1 = y0, y1
       j2 = jh + j1
       do i1 = x0, x1
        i2 = ih + i1
        jcurr(i2, j2, 1, 1) = jcurr(i2, j2, 1, 1) + ayh(j1)*currx(i1)
       end do
      end do
      !================dt*J_y= curry*(Wx^0+Wx^1)
      do j1 = y0, y1
       j2 = jh + j1
       do i1 = x0, x1
        i2 = ih + i1
        jcurr(i2, j2, 1, 2) = jcurr(i2, j2, 1, 2) + axh(i1)*curry(j1)
       end do
      end do
      !========== dt*J_z Vz*[Wy^0(Wx^0+0.5*Wx^1)+Wy^1*(Wx^1+0.5*Wx^0)]
      do j1 = 0, 2
       j2 = jj0 + j1
       dvol = ay0(j1)*vp(3)
       do i1 = x0, x1
        i2 = i1 + ih
        jcurr(i2, j2, 1, 3) = jcurr(i2, j2, 1, 3) + axh0(i1)*dvol
       end do
       j2 = j + j1
       dvol = ay1(j1)*vp(3)
       do i1 = x0, x1
        i2 = i1 + ih
        jcurr(i2, j2, 1, 3) = jcurr(i2, j2, 1, 3) + axh1(i1)*dvol
       end do
      end do
     end do
    end if
   end select
   !-----------------------
  end subroutine
  !==========================================
  !=============3D=================
  subroutine esirkepov_3d_curr(sp_loc, pt, jcurr, np)

   type (species), intent (in) :: sp_loc
   real (dp), intent (inout) :: pt(:, :), jcurr(:, :, :, :)
   integer, intent (in) :: np
   real (dp) :: dvol, dvolh
   real (dp) :: ax0(0:2), ay0(0:2), az0(0:2), xp0(1:3)
   real (dp) :: ax1(0:2), ay1(0:2), az1(0:2), xp1(1:3)
   real (dp) :: axh(0:4), ayh(0:4), azh(0:4)
   real (dp) :: axh0(0:4), axh1(0:4), ayh0(0:4), ayh1(0:4)
   real (dp) :: currx(0:4), curry(0:4), currz(0:4)
   real (sp) :: wght
   integer :: i, j, k, ii0, jj0, kk0, i1, j1, k1, i2, j2, k2, n
   integer :: x0, x1, y0, y1, z0, z1, ih, jh, kh
   !=======================
   !Enter pt(4:6) old positions sp_loc(1:3) new positions

   ax1(0:2) = zero_dp
   ay1(0:2) = zero_dp
   az1(0:2) = zero_dp
   az0(0:2) = zero_dp
   ax0(0:2) = zero_dp
   ay0(0:2) = zero_dp
   axh(0:4) = zero_dp
   ayh(0:4) = zero_dp
   azh(0:4) = zero_dp
   currx(0:4) = zero_dp
   curry(0:4) = zero_dp
   currz(0:4) = zero_dp
   axh0(0:4) = zero_dp
   ayh0(0:4) = zero_dp
   axh1(0:4) = zero_dp
   ayh1(0:4) = zero_dp
   ! ==============================Only new and old positions needed
   do n = 1, np
    pt(n, 1:3) = sp_loc%part(n, 1:3) !x-y-z -new  t^(n+1)
    wgh_cmp = sp_loc%part(n, 7)
    wght = charge*wgh
    pt(n, 7) = wght
   end do
   call set_local_3d_positions(pt, 2, np)
   do n = 1, np
    wght = real(pt(n,7), sp)
    xp1(1:3) = pt(n, 1:3) !increments of the new positions
    xp0(1:3) = pt(n, 4:6) !increments of old positions
    call qden_3d_wgh(xp0, ax0, ay0, az0, ii0, jj0, kk0)
    call qden_3d_wgh(xp1, ax1, ay1, az1, i, j, k)

    axh(0:4) = zero_dp
    ih = i - ii0 + 1
    !========== direct Jx-inversion
    do i1 = 0, 2
     axh(ih+i1) = ax1(i1)
    end do
    currx(0) = -axh(0)
    do i1 = 1, 3
     currx(i1) = currx(i1-1) + ax0(i1-1) - axh(i1)
    end do
    currx(4) = currx(3) - axh(4)
    currx(0:4) = wght*currx(0:4)
    !=======================
    axh0(0:4) = 0.5*axh(0:4)
    axh1(0:4) = axh(0:4)
    do i1 = 1, 3
     axh0(i1) = axh0(i1) + ax0(i1-1)
     axh1(i1) = axh1(i1) + 0.5*ax0(i1-1)
    end do

    x0 = min(ih, 1)
    x1 = max(ih+2, 3)
    !-------
    i = i - 1
    ii0 = ii0 - 1

    !========== direct Jy-inversion
    jh = j - jj0 + 1 !=[0,1,2]
    ayh(0:4) = zero_dp
    do i1 = 0, 2
     ayh(jh+i1) = ay1(i1)
    end do
    curry(0) = -ayh(0)
    do i1 = 1, 3
     curry(i1) = curry(i1-1) + ay0(i1-1) - ayh(i1)
    end do
    curry(4) = curry(3) - ayh(4)
    curry(0:4) = wght*curry(0:4)
    !=====================================
    !                                 Jx =>    Wz^0(0.5*wy^1+Wy^0)=Wz^0*ayh0
    !                                          Wz^1(wy^1+0.5*Wy^0)=Wz^1*ayh1
    !==============================
    ayh0(0:4) = 0.5*ayh(0:4)
    ayh1(0:4) = ayh(0:4)
    do i1 = 1, 3
     ayh0(i1) = ayh0(i1) + ay0(i1-1)
     ayh1(i1) = ayh1(i1) + 0.5*ay0(i1-1)
    end do
    y0 = min(jh, 1) ![0,1]
    y1 = max(jh+2, 3) ![3,4]
    !-----------
    jj0 = jj0 - 1
    j = j - 1

    ! Direct Jz inversion
    kh = k - kk0 + 1
    azh(0:4) = zero_dp
    do i1 = 0, 2
     azh(kh+i1) = az1(i1)
    end do
    currz(0) = -azh(0)
    do i1 = 1, 3
     currz(i1) = currz(i1-1) + az0(i1-1) - azh(i1)
    end do
    currz(4) = currz(3) - azh(4)
    currz(0:4) = wght*currz(0:4)
    !----------
    kk0 = kk0 - 1
    k = k - 1
    z0 = min(kh, 1)
    z1 = max(kh+2, 3)
    !================Jx=DT*drho_x to be inverted==================
    jh = jj0 - 1
    !====================
    ih = ii0 - 1
    do k1 = 0, 2
     do j1 = y0, y1
      j2 = jh + j1
      dvol = ayh0(j1)*az0(k1)
      dvolh = ayh1(j1)*az1(k1)
      do i1 = x0, x1
       i2 = ih + i1
       jcurr(i2, j2, kk0+k1, 1) = jcurr(i2, j2, kk0+k1, 1) + &
         dvol*currx(i1)
       jcurr(i2, j2, k+k1, 1) = jcurr(i2, j2, k+k1, 1) + dvolh*currx(i1)
      end do
     end do
    end do
    !================Jy
    do k1 = 0, 2
     do j1 = y0, y1
      j2 = jh + j1
      dvol = curry(j1)*az0(k1)
      dvolh = curry(j1)*az1(k1)
      do i1 = x0, x1
       i2 = ih + i1
       jcurr(i2, j2, kk0+k1, 2) = jcurr(i2, j2, kk0+k1, 2) + axh0(i1)*dvol
       jcurr(i2, j2, k+k1, 2) = jcurr(i2, j2, k+k1, 2) + axh1(i1)*dvolh
      end do
     end do
    end do
    !================Jz
    kh = kk0 - 1

    do k1 = z0, z1
     k2 = kh + k1
     do j1 = 0, 2
      dvol = ay0(j1)*currz(k1)
      dvolh = ay1(j1)*currz(k1)
      do i1 = x0, x1
       i2 = ih + i1
       jcurr(i2, jj0+j1, k2, 3) = jcurr(i2, jj0+j1, k2, 3) + axh0(i1)*dvol
       jcurr(i2, j+j1, k2, 3) = jcurr(i2, j+j1, k2, 3) + axh1(i1)*dvolh
      end do
     end do
    end do
   end do
   !============= Curr data on [1:n+4] extended range
  end subroutine
  !===============================
  ! NO CHARGE PRESERVING CURRENT DENSITY
  !=========================
  subroutine ncdef_2d_curr(sp_loc, pt, jcurr, np)

   type (species), intent (in) :: sp_loc
   real (dp), intent (inout) :: pt(:, :), jcurr(:, :, :, :)
   integer, intent (in) :: np
   real (dp) :: axh0(0:2), ayh0(0:2)
   real (dp) :: axh1(0:2), ayh1(0:2)
   real (dp) :: ax0(0:2), ay0(0:2), xp0(1:2)
   real (dp) :: ax1(0:2), ay1(0:2), xp1(1:2)
   real (dp) :: vp(3), dvol(3)
   real (sp) :: wght
   integer :: i, j, ii0, jj0, i1, j1, i2, j2, n
   integer :: jh0, jh, ih0, ih
   !=======================
   !Enter pt(3:4) old x-y positions
   !=====================================
   do n = 1, np
    pt(n, 1:2) = sp_loc%part(n, 1:2) !(x,y,z) new
   end do
   call set_local_2d_positions(pt, 2, np)
   !========== pt(n,5) = dt/gam
   do n = 1, np
    wgh_cmp = sp_loc%part(n, 5)
    wght = charge*wgh !w*q for  q=e, ion_charge
    vp(1:2) = wght*pt(n, 5)*sp_loc%part(n, 3:4) !dt*q*wgh*P/gam at t^{n+1/2}
    vp(1:2) = 0.5*vp(1:2) !1/2 * V*q*wgh*dt

    xp1(1:2) = pt(n, 1:2)
    xp0(1:2) = pt(n, 3:4)
    call qlh_2d_spline(xp0, ax0, axh0, ay0, ayh0, ii0, ih0, jj0, jh0)
    !====================
    call qlh_2d_spline(xp1, ax1, axh1, ay1, ayh1, i, ih, j, jh)

    !===============Jx ========
    do j1 = 0, 2
     j2 = j + j1
     dvol(1) = vp(1)*ay1(j1)
     do i1 = 0, 1
      i2 = ih + i1
      jcurr(i2, j2, 1, 1) = jcurr(i2, j2, 1, 1) + dvol(1)*axh1(i1)
     end do
     j2 = jj0 + j1
     dvol(1) = vp(1)*ay0(j1)
     do i1 = 0, 1
      i2 = ih0 + i1
      jcurr(i2, j2, 1, 1) = jcurr(i2, j2, 1, 1) + dvol(1)*axh0(i1)
     end do
    end do
    !=========== Jy             
    do j1 = 0, 1
     j2 = jh0 + j1
     dvol(2) = vp(2)*ayh0(j1)
     do i1 = 0, 2
      i2 = ii0 + i1
      jcurr(i2, j2, 1, 2) = jcurr(i2, j2, 1, 2) + dvol(2)*ax0(i1)
     end do
     j2 = jh + j1
     dvol(2) = vp(2)*ayh1(j1)
     do i1 = 0, 2
      i2 = i + i1
      jcurr(i2, j2, 1, 2) = jcurr(i2, j2, 1, 2) + dvol(2)*ax1(i1)
     end do
    end do
   end do
  end subroutine
  !========================
  subroutine ncdef_3d_curr(sp_loc, pt, jcurr, np)

   type (species), intent (in) :: sp_loc
   real (dp), intent (inout) :: pt(:, :), jcurr(:, :, :, :)
   integer, intent (in) :: np
   real (dp) :: dvol(3), gam_inv
   real (dp) :: xp0(3), xp1(3)
   real (dp) :: ax0(0:2), ay0(0:2), az0(0:2)
   real (dp) :: ax1(0:2), ay1(0:2), az1(0:2)
   real (dp) :: axh0(0:1), ayh0(0:1), azh0(0:1)
   real (dp) :: axh1(0:1), ayh1(0:1), azh1(0:1)
   real (dp) :: vp(3)
   real (sp) :: wght
   integer :: i, j, k, ii0, jj0, kk0, i1, j1, k1, i2, j2, k2, n
   integer :: ih, jh, kh, ih0, jh0, kh0
   !=======================
   ! Current densities defined by alternating order (quadratic/linear) shapes
   ! Enter pt(4:6)=old positions sp_loc(1:3)=new positions 
   !WARNING : to be used ONLY within the one cycle partcle integration scheme
   !==========================================
   ! Exit in jcurr(1:3) =[Drho,J_y,J_z]   !Drho= rho^{new}-rho^{old}
   ! Component J_x recovered by enforcing the continuity equation on a grid
   !=============================================

   do n = 1, np
    pt(n, 1:3) = sp_loc%part(n, 1:3) !(x,y,z) new
   end do
   call set_local_3d_positions(pt, 2, np)

   do n = 1, np
    vp(1:3) = sp_loc%part(n, 4:6) !Momenta at t^{n+1/2}
    wgh_cmp = sp_loc%part(n, 7)
    wght = real(charge*wgh, sp) !w*q for  q=charge
    gam_inv = wght*pt(n, 7) !q*wgh*dt/gam               
    vp(1:3) = 0.5*gam_inv*vp(1:3) !wgh*q*dt*V factor 1/2 from density average

    xp1(1:3) = pt(n, 1:3) !new relative coordinates
    xp0(1:3) = pt(n, 4:6) !old relative coordinates

    call qlh_3d_spline(xp0, ax0, axh0, ay0, ayh0, az0, azh0, ii0, ih0, &
      jj0, jh0, kk0, kh0)
    !====================
    call qlh_3d_spline(xp1, ax1, axh1, ay1, ayh1, az1, azh1, i, ih, j, &
      jh, k, kh)
    !======================   Jx
    do k1 = 0, 2
     k2 = k + k1
     do j1 = 0, 2
      j2 = j + j1
      dvol(1) = vp(1)*ay1(j1)*az1(k1)
      do i1 = 0, 1
       i2 = ih + i1
       jcurr(i2, j2, k2, 1) = jcurr(i2, j2, k2, 1) + dvol(1)*axh1(i1)
      end do
     end do
     k2 = kk0 + k1
     do j1 = 0, 2
      j2 = jj0 + j1
      dvol(1) = vp(1)*ay0(j1)*az0(k1)
      do i1 = 0, 1
       i2 = ih0 + i1
       jcurr(i2, j2, k2, 1) = jcurr(i2, j2, k2, 1) + dvol(1)*axh0(i1)
      end do
     end do
    end do
    !================Jy-Jz=============
    do k1 = 0, 2
     k2 = kk0 + k1
     do j1 = 0, 1
      j2 = jh0 + j1
      dvol(2) = vp(2)*ayh0(j1)*az0(k1)
      do i1 = 0, 2
       i2 = ii0 + i1
       jcurr(i2, j2, k2, 2) = jcurr(i2, j2, k2, 2) + dvol(2)*ax0(i1)
      end do
     end do
     k2 = k + k1
     do j1 = 0, 1
      j2 = jh + j1
      dvol(2) = vp(2)*ayh1(j1)*az1(k1)
      do i1 = 0, 2
       i2 = i + i1
       jcurr(i2, j2, k2, 2) = jcurr(i2, j2, k2, 2) + dvol(2)*ax1(i1)
      end do
     end do
    end do
    do k1 = 0, 1
     k2 = kh0 + k1
     do j1 = 0, 2
      j2 = jj0 + j1
      dvol(3) = vp(3)*ay0(j1)*azh0(k1)
      do i1 = 0, 2
       i2 = ii0 + i1
       jcurr(i2, j2, k2, 3) = jcurr(i2, j2, k2, 3) + dvol(3)*ax0(i1)
      end do
     end do
     k2 = kh + k1
     do j1 = 0, 2
      j2 = j + j1
      dvol(3) = vp(3)*ay1(j1)*azh1(k1)
      do i1 = 0, 2
       i2 = i + i1
       jcurr(i2, j2, k2, 3) = jcurr(i2, j2, k2, 3) + dvol(3)*ax1(i1)
      end do
     end do
    end do
   end do
   !============= Curr and density data on [0:n+3] extended range
  end subroutine
  !==========================
 end module
