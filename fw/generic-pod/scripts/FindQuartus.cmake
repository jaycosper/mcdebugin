include(FindPackageHandleStandardArgs)

set(QUARTUS_HINTS
    /opt/altera/*/quartus/bin
    /opt/intelFPGA/*/quartus/bin
    $ENV{QUARTUS_ROOTDIR}/../quartus/bin
)

find_program(QUARTUS_SH_EXECUTABLE NAMES quartus_sh PATHS ${QUARTUS_HINTS})
find_program(QUARTUS_PGM_EXECUTABLE NAMES quartus_pgm PATHS ${QUARTUS_HINTS})

find_package_handle_standard_args(Quartus
    REQUIRED_VARS QUARTUS_SH_EXECUTABLE
    HANDLE_COMPONENTS
)

mark_as_advanced(QUARTUS_SH_EXECUTABLE QUARTUS_PGM_EXECUTABLE)
