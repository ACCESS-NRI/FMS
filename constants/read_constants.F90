!! \brief Subroutines for reading FMS constants from the namelist


module read_constants_mod
  use constants_mod, only: HLV, HLS, HLF
  implicit none
  private

  public read_fms_constants

  contains

  ! <SUBROUTINE NAME="read_fms_constants">
  !   <OVERVIEW>
  !     Read runtime configurable constants from the fms_constants_nml namelist.
  !   </OVERVIEW>
  !   <TEMPLATE>
  !     call read_fms_constants ()
  !   </TEMPLATE>
  !   <DESCRIPTION>
  !     Some constants can be configured in the fms_constants_nml namelist. Read the namelist
  !     and overwrite the default values.
  !   </DESCRIPTION>
  !   <INOUT NAME="output_field" TYPE="TYPE(output_field_type)">Output field that needs the cell_measures</INOUT>
  !   <IN NAME="area" TYPE="INTEGER, OPTIONAL">Field ID for area</IN>
  !   <IN NAME="volume" TYPE="INTEGER, OPTIONAL">Field ID for volume</IN>
  !   <OUT NAME="err_msg" TYPE="CHARACTER(len=*), OPTIONAL"> </OUT>
  subroutine read_fms_constants
    USE fms_mod, ONLY: check_nml_error, stdlog
    USE mpp_mod, ONLY: mpp_pe, mpp_root_pe
#ifdef INTERNAL_FILE_NML
    USE mpp_mod, ONLY: input_nml_file
#else
    USE fms_mod, ONLY: open_namelist_file, close_file
    INTEGER :: nml_unit
#endif
    integer :: mystat, ierr, stdlog_unit

    NAMELIST /fms_constants_nml/ hlv

#ifdef INTERNAL_FILE_NML
    READ (input_nml_file, NML=fms_constants_nml, IOSTAT=mystat)
#else
    if ( file_exist('input.nml') ) then
      nml_unit = open_namelist_file ( )
      ierr=1
      do while (ierr > 0)
        read  (nml_unit, nml=fms_constants_nml, iostat=mystat)
        ierr = check_nml_error(mystat,'fms_constants_nml')
      enddo
        call close_file (nml_unit)
    endif
#endif

    stdlog_unit = stdlog()
    IF ( mpp_pe() == mpp_root_pe() ) THEN
      WRITE (stdlog_unit, fms_constants_nml)
    END IF

    ! Set HLS using the updated value of HLV
    HLS = HLV + HLF 

end subroutine read_fms_constants