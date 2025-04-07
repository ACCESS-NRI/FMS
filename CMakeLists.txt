#***********************************************************************
#*                   GNU Lesser General Public License
#*
#* This file is part of the GFDL Flexible Modeling System (FMS).
#*
#* FMS is free software: you can redistribute it and/or modify it under
#* the terms of the GNU Lesser General Public License as published by
#* the Free Software Foundation, either version 3 of the License, or (at
#* your option) any later version.
#*
#* FMS is distributed in the hope that it will be useful, but WITHOUT
#* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#* FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#* for more details.
#*
#* You should have received a copy of the GNU Lesser General Public
#* License along with FMS.  If not, see <http://www.gnu.org/licenses/>.
#***********************************************************************

# Copyright (c) GFDL, @underwoo

cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

# Define the CMake project
project(FMS
  VERSION 2020.03.001
  # Forked in 2020 at: https://github.com/ACCESS-NRI/FMS/commit/e8940fe90d68c3dc7c0d6bf1b8f552a577251754
  DESCRIPTION "ACCESS-NRI fork of GFDL FMS Library"
  HOMEPAGE_URL "https://github.com/ACCESS-NRI/FMS/"
  LANGUAGES C Fortran)

include(GNUInstallDirs)

if(NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Release|RelWithDebInfo|MinSizeRel)$")
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE
      "Release"
      CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

if(NOT CMAKE_C_COMPILER_ID MATCHES "^(Intel|GNU|Clang|IntelLLVM)$")
  message(
    WARNING "Compiler not officially supported: ${CMAKE_C_COMPILER_ID}")
endif()

if(NOT CMAKE_Fortran_COMPILER_ID MATCHES "^(Intel|GNU|IntelLLVM)$")
  message(
    WARNING "Compiler not officially supported: ${CMAKE_Fortran_COMPILER_ID}")
endif()

# Append directory that contains CMake Modules for building FMS
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

################################################################################
# Fortran
################################################################################

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")

  # Precision-based Fortran compiler flags
  set(r8_flags "-fdefault-real-8 -fdefault-double-8") # Fortran flags for 64BIT precision

  # Copied from MOM5/bin/mkmf.template.nci.gfortran
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fcray-pointer -fdefault-real-8 -ffree-line-length-none -fno-range-check -Waliasing -Wampersand -Warray-bounds -Wcharacter-truncation -Wconversion -Wline-truncation -Wintrinsics-std -Wsurprising -Wno-tabs -Wunderflow -Wunused-parameter -Wintrinsic-shadow -Wno-align-commons")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O2")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -W -fbounds-check")

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")

  # Precision-based Fortran compiler flags
  set(r4_flags "-real-size 32") # Fortran flags for 32BIT precision
  set(r8_flags "-real-size 64") # Fortran flags for 64BIT precision
  set(r8_flags "${r8_flags} -no-prec-div -no-prec-sqrt")

  # Copied from MOM5/bin/mkmf.template.nci
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fno-alias -safe-cray-ptr -fpe0 -ftz -assume byterecl -i4 -r8 -traceback -nowarn -check noarg_temp_created -assume nobuffered_io -convert big_endian -grecord-gcc-switches -align all")
  set(CMAKE_Fortran_FLAGS_RELEASE "-g3 -O2 -xCORE-AVX2 -debug all -check none")
  set(CMAKE_Fortran_FLAGS_DEBUG "-g3 -O0 -debug all -check -check noarg_temp_created -check nopointer -warn -warn noerrors -ftrapuv")

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")

  # Precision-based Fortran compiler flags
  set(r4_flags "-real-size 32") # Fortran flags for 32BIT precision
  set(r8_flags "-real-size 64") # Fortran flags for 64BIT precision

  # Copied from MOM5/bin/mkmf.template.nci
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fno-alias -safe-cray-ptr -fpe0 -ftz -assume byterecl -i4 -r8 -traceback -nowarn -check noarg_temp_created -assume nobuffered_io -convert big_endian -grecord-gcc-switches -align all")
  set(CMAKE_Fortran_FLAGS_RELEASE "-g3 -O2 -xCORE-AVX2 -debug all -check none")
  set(CMAKE_Fortran_FLAGS_DEBUG "-g3 -O0 -debug all -check -check noarg_temp_created -check nopointer -warn -warn noerrors -ftrapuv")

else()
  message(WARNING "Fortran compiler with ID ${CMAKE_Fortran_COMPILER_ID} will be used with CMake default options")
endif()

################################################################################
# C
################################################################################

if(CMAKE_C_COMPILER_ID MATCHES "GNU")

  # Copied from MOM5/bin/mkmf.template.nci.gfortran
  set(CMAKE_C_FLAGS         "${CMAKE_C_FLAGS}")
  set(CMAKE_C_FLAGS_DEBUG   "-O0 -g")
  set(CMAKE_C_FLAGS_RELEASE "-O2")

elseif(CMAKE_C_COMPILER_ID STREQUAL "Intel")

  # Copied from MOM5/bin/mkmf.template.nci
  set(CMAKE_C_FLAGS         "${CMAKE_C_FLAGS}")
  set(CMAKE_C_FLAGS_DEBUG   "-O0 -g -ftrapuv -traceback")
  set(CMAKE_C_FLAGS_RELEASE "-O2 -debug minimal -xCORE-AVX2")

elseif(CMAKE_C_COMPILER_ID STREQUAL "IntelLLVM")

  # Copied from MOM5/bin/mkmf.template.nci
  set(CMAKE_C_FLAGS         "${CMAKE_C_FLAGS}")
  set(CMAKE_C_FLAGS_DEBUG   "-O0 -g -ftrapuv -traceback")
  set(CMAKE_C_FLAGS_RELEASE "-O2 -debug minimal -xCORE-AVX2")

elseif(CMAKE_C_COMPILER_ID MATCHES "Clang")

  # Copied from MOM5/bin/mkmf.template.nci.gfortran
  set(CMAKE_C_FLAGS         "${CMAKE_C_FLAGS}")
  set(CMAKE_C_FLAGS_DEBUG   "-O0 -g")
  set(CMAKE_C_FLAGS_RELEASE "-O2")

else()
  message(WARNING "C compiler with ID ${CMAKE_C_COMPILER_ID} will be used with CMake default options")
endif()

################################################################################

# Build options
option(OPENMP      "Build FMS with OpenMP support"        OFF)
# Commented out while CMAKE_Fortran_FLAGS contains -r8
# option(32BIT       "Build 32-bit (r4) FMS library"        OFF)
# Refer to CMAKE_Fortran_FLAGS above, it contains -r8
option(64BIT       "Build 64-bit (r8) FMS library"        ON)
option(FPIC        "Build with position independent code" OFF)
option(SHARED_LIBS "Build shared/dynamic libraries"       OFF)

# Options for compiler definitions
option(INTERNAL_FILE_NML     "Enable compiler definition -DINTERNAL_FILE_NML"      ON)
option(PORTABLE_KINDS        "Enable compiler definition -DPORTABLE_KINDS"        OFF)
option(GFS_PHYS              "Enable compiler definition -DGFS_PHYS"              OFF)
option(LARGEFILE             "Enable compiler definition -Duse_LARGEFILE"         OFF)

if(32BIT)
  list(APPEND kinds "r4")
endif()
if(64BIT)
  list(APPEND kinds "r8")
endif()
if(NOT kinds)
  message(STATUS "Single Precision 32BIT: ${32BIT}")
  message(STATUS "Double Precision 64BIT: ${64BIT}")
  message(FATAL_ERROR "Either 32BIT or 64BIT should be ON")
endif()

# Find dependencies
find_package(MPI REQUIRED COMPONENTS C Fortran)
find_package(NetCDF REQUIRED COMPONENTS C Fortran)

# Check for the OpenMP library and set the required compile flags
if (OPENMP)
  find_package(OpenMP REQUIRED COMPONENTS C Fortran)
endif()

# Enables position independent code (i.e., -fPIC)
if (FPIC)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif ()

# Collect FMS Fortran source files
list(APPEND fms_fortran_src_files
  amip_interp/amip_interp.F90
  astronomy/astronomy.F90
  axis_utils/axis_utils.F90
  block_control/block_control.F90
  column_diagnostics/column_diagnostics.F90
  constants/constants.F90
  coupler/atmos_ocean_fluxes.F90
  coupler/coupler_types.F90
  coupler/ensemble_manager.F90
  data_override/data_override.F90
  diag_manager/diag_axis.F90
  diag_manager/diag_data.F90
  diag_manager/diag_grid.F90
  diag_manager/diag_manager.F90
  diag_manager/diag_manifest.F90
  diag_manager/diag_output.F90
  diag_manager/diag_table.F90
  diag_manager/diag_util.F90
  drifters/cloud_interpolator.F90
  drifters/drifters.F90
  drifters/drifters_comm.F90
  drifters/drifters_core.F90
  drifters/drifters_input.F90
  drifters/drifters_io.F90
  drifters/quicksort.F90
  exchange/stock_constants.F90
  exchange/xgrid.F90
  field_manager/field_manager.F90
  field_manager/fm_util.F90
  fft/fft99.F90
  fft/fft.F90
  fms/fms_io.F90
  fms/fms.F90
  horiz_interp/horiz_interp_bicubic.F90
  horiz_interp/horiz_interp_bilinear.F90
  horiz_interp/horiz_interp_conserve.F90
  horiz_interp/horiz_interp_spherical.F90
  horiz_interp/horiz_interp_type.F90
  horiz_interp/horiz_interp.F90
  interpolator/interpolator.F90
  memutils/memutils.F90
  mosaic/gradient.F90
  mosaic/grid.F90
  mosaic/mosaic.F90
  mpp/mpp.F90
  mpp/mpp_data.F90
  mpp/mpp_domains.F90
  mpp/mpp_efp.F90
  mpp/mpp_io.F90
  mpp/mpp_memutils.F90
  mpp/mpp_parameter.F90
  mpp/mpp_pset.F90
  mpp/mpp_utilities.F90
  oda_tools/oda_core_ecda.F90
  oda_tools/oda_core.F90
  oda_tools/oda_types.F90
  oda_tools/write_ocean_data.F90
  oda_tools/xbt_drop_rate_adjust.f90
  platform/platform.F90
  random_numbers/MersenneTwister.F90
  random_numbers/random_numbers.F90
  sat_vapor_pres/sat_vapor_pres_k.F90
  sat_vapor_pres/sat_vapor_pres.F90
  station_data/station_data.F90
  time_interp/time_interp_external.F90
  time_interp/time_interp.F90
  time_manager/get_cal_time.F90
  time_manager/time_manager.F90
  topography/gaussian_topog.F90
  topography/topography.F90
  tracer_manager/tracer_manager.F90
  tridiagonal/tridiagonal.F90
)

# Collect FMS C source files
list(APPEND fms_c_src_files
  memutils/memuse.c
  mosaic/create_xgrid.c
  mosaic/gradient_c2l.c
  mosaic/interp.c
  mosaic/mosaic_util.c
  mosaic/read_mosaic.c
  mpp/affinity.c
  mpp/nsclock.c
  mpp/threadloc.c
)

# Collect FMS header files
list(APPEND fms_header_files
  include/file_version.h
  include/fms_platform.h
)

# Standard FMS compiler definitions
list(APPEND fms_defs
  use_libMPI
  use_netCDF
  SPMD
  __IFC)

# check gettid
include(CheckFunctionExists)
check_function_exists(gettid HAVE_GETTID)
if(HAVE_GETTID)
  list(APPEND fms_defs HAVE_GETTID)
endif()

if(GFS_PHYS)
  list(APPEND fms_defs GFS_PHYS)
endif()

if(INTERNAL_FILE_NML)
  list(APPEND fms_defs INTERNAL_FILE_NML)
endif()

if(ENABLE_QUAD_PRECISION)
  list(APPEND fms_defs ENABLE_QUAD_PRECISION)
endif()

if(PORTABLE_KINDS)
  list(APPEND fms_defs PORTABLE_KINDS)
endif()

if(LARGEFILE)
  list(APPEND fms_defs use_LARGEFILE)
endif()

# Precision-based compiler definitions
if(32BIT)
  list(APPEND r4_defs OVERLOAD_R4 OVERLOAD_R8)
endif()

# Add platform specific compiler definitions
if(APPLE)
  list(APPEND fms_defs __APPLE__)
endif()

foreach(kind ${kinds})

  set(libTgt fms_${kind})
  set(includeDir "include_${kind}")
  set(moduleDir "${CMAKE_CURRENT_BINARY_DIR}/${includeDir}")

  # C
  add_library(${libTgt}_c OBJECT ${fms_c_src_files})

  target_include_directories(${libTgt}_c PRIVATE include
                                                 mosaic
                                                 drifters
                                                 fms
                                                 mpp/include)

  target_compile_definitions(${libTgt}_c PRIVATE "${fms_defs}")

  target_link_libraries(${libTgt}_c PRIVATE NetCDF::NetCDF_C
                                            MPI::MPI_C)

  if(OpenMP_C_FOUND)
    target_link_libraries(${libTgt}_c PRIVATE OpenMP::OpenMP_C)
  endif()

  # Fortran
  add_library(${libTgt}_f OBJECT ${fms_fortran_src_files})

  target_include_directories(${libTgt}_f PRIVATE include
                                                 mosaic
                                                 drifters
                                                 fms
                                                 mpp/include)

  target_compile_definitions(${libTgt}_f PRIVATE "${fms_defs}")
  target_compile_definitions(${libTgt}_f PRIVATE "${${kind}_defs}")

  set_target_properties(${libTgt}_f PROPERTIES COMPILE_FLAGS "${${kind}_flags}")

  set_target_properties(${libTgt}_f PROPERTIES Fortran_MODULE_DIRECTORY
                                               ${moduleDir})

  target_link_libraries(${libTgt}_f PRIVATE NetCDF::NetCDF_Fortran
                                            MPI::MPI_Fortran)

  if(OpenMP_Fortran_FOUND)
    target_link_libraries(${libTgt}_f PRIVATE OpenMP::OpenMP_Fortran)
  endif()

  # Check if gnu 10 or higher
  # this should only be needed with mpich, but wasn't able to find a good way to find the MPI flavor consistently
  if ( CMAKE_Fortran_COMPILER_VERSION MATCHES "1[0-9]\.[0-9]*\.[0-9]*" AND CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    include(CheckFortranCompilerFlag)
    check_fortran_compiler_flag("-fallow-argument-mismatch" _arg_mismatch_flag)
    if(_arg_mismatch_flag)
      message(STATUS "Adding -fallow-argument-mismatch flag to compile with GCC >=10 and MPICH")
      target_compile_options(${libTgt}_f PRIVATE "-fallow-argument-mismatch;-w")
    endif()
  endif()

  # FMS (C + Fortran)
  if (SHARED_LIBS)
      message(STATUS "Shared library target: ${libTgt}")
      add_library(${libTgt} SHARED $<TARGET_OBJECTS:${libTgt}_c>
                                   $<TARGET_OBJECTS:${libTgt}_f>)
  else ()
      message(STATUS "Static library target: ${libTgt}")
      add_library(${libTgt} STATIC $<TARGET_OBJECTS:${libTgt}_c>
                                   $<TARGET_OBJECTS:${libTgt}_f>)
  endif ()

  target_include_directories(${libTgt} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/mpp/include>)

  target_include_directories(${libTgt} INTERFACE
    $<BUILD_INTERFACE:${moduleDir}>
    $<INSTALL_INTERFACE:${includeDir}>)

  target_compile_definitions(${libTgt} PRIVATE "${fms_defs}")
  target_compile_definitions(${libTgt} PRIVATE "${${kind}_defs}")

  target_link_libraries(${libTgt} PUBLIC NetCDF::NetCDF_C
                                         NetCDF::NetCDF_Fortran
                                         MPI::MPI_Fortran)

  if(OpenMP_Fortran_FOUND)
    target_link_libraries(${libTgt} PRIVATE OpenMP::OpenMP_C OpenMP::OpenMP_Fortran)
  endif()

  add_library(FMS::${libTgt} ALIAS ${libTgt})

  list(APPEND LIB_TARGETS ${libTgt})
  install(DIRECTORY ${moduleDir}    DESTINATION ${CMAKE_INSTALL_PREFIX})
  install(FILES ${fms_header_files} DESTINATION ${CMAKE_INSTALL_PREFIX}/${includeDir})

endforeach()

install(
  TARGETS ${LIB_TARGETS}
  EXPORT FMSExports
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

### Package config
include(CMakePackageConfigHelpers)
set(CONFIG_INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/fms)

export(EXPORT FMSExports
  NAMESPACE FMS::
  FILE fms-targets.cmake)

configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/FMSConfig.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/fms-config.cmake
  INSTALL_DESTINATION ${CONFIG_INSTALL_DESTINATION})
install(FILES ${CMAKE_SOURCE_DIR}/cmake/FindNetCDF.cmake ${CMAKE_CURRENT_BINARY_DIR}/fms-config.cmake
  DESTINATION ${CONFIG_INSTALL_DESTINATION})

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/fms-config-version.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/fms-config-version.cmake
  DESTINATION ${CONFIG_INSTALL_DESTINATION})

install(EXPORT FMSExports
  NAMESPACE FMS::
  FILE fms-targets.cmake
  DESTINATION ${CONFIG_INSTALL_DESTINATION})

# pkgconf
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${CMAKE_INSTALL_PREFIX})
set(libdir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
set(includedir ${CMAKE_INSTALL_PREFIX}/${includeDir})

set(CC ${CMAKE_C_COMPILER})
set(FC ${CMAKE_Fortran_COMPILER})
set(CFLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}}")
set(CPPFLAGS "${CMAKE_CPP_FLAGS} ${CMAKE_CPP_FLAGS_${CMAKE_BUILD_TYPE}}")
set(FCFLAGS "${CMAKE_Fortran_FLAGS} ${CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE}}")
set(LDFLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_${CMAKE_BUILD_TYPE}}")

set(VERSION ${PROJECT_VERSION})

# TODO: If FMS depends on a library that is built as a static library, it
#       should be listed here as an ldflag.
set(LIBS "")

if(NOT ${NetCDF_Fortran_LIBRARY_SHARED})
  # autotools: Libs.private: -lnetcdff -lnetcdf
  string(APPEND LIBS ${NetCDF_Fortran_LIBRARIES})
endif()

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/FMS.pc.in
               ${CMAKE_CURRENT_BINARY_DIR}/FMS.pc @ONLY)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/FMS.pc
              DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
              COMPONENT utilities)
