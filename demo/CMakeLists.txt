cmake_minimum_required( VERSION 3.15...99.99)

project( demos C)

#
# Turn an "Executable" into a "Library"
# * mulle-sde test init
# * mv src/main.m test/10_test/test.m
# Then set MULLE_PROJECT_TYPE to "Library".
# * mulle-sde reflect
# * mulle-sde test
#
set( MULLE_PROJECT_TYPE "Executable")

### mulle-sde environment

# add cmake module paths to search path
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/share")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/reflect")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake")

add_compile_definitions( -DMULLE_CG_GLVERSION=1)

include( Environment)

include( Files)

# Find mulle-c-string-escape
find_program(MULLE_C_STRING_ESCAPE mulle-c-string-escape
             PATHS "~/bin")

# apt install glslang-tools
#find_program( GLSLANG_VALIDATOR glslangValidator
#             PATHS "~/bin")

# Create a custom command to generate the *.inc files
foreach( SHADER ${SHADERS})
   set( INC_FILE "${SHADER}.inc")
   set( INC_FILE_ABSOLUTE "${PROJECT_SOURCE_DIR}/${INC_FILE}")
   set( SHADER_ABSOLUTE "${PROJECT_SOURCE_DIR}/${SHADER}")
   if( GLSLANG_VALIDATOR)
      add_custom_command(
         OUTPUT "${INC_FILE_ABSOLUTE}"
         COMMAND "${GLSLANG_VALIDATOR}" "${SHADER_ABSOLUTE}" &&
                 "${MULLE_C_STRING_ESCAPE}" -0 -q "${SHADER_ABSOLUTE}" > "${INC_FILE_ABSOLUTE}"
         WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
         DEPENDS "${SHADER_ABSOLUTE}"
         COMMENT "Generating ${INC_FILE} from ${SHADER}"
      )
   else()
      if( MULLE_C_STRING_ESCAPE)
          add_custom_command(
            OUTPUT "${INC_FILE_ABSOLUTE}"
            COMMAND "${MULLE_C_STRING_ESCAPE}" -0 -q "${SHADER_ABSOLUTE}" > "${INC_FILE_ABSOLUTE}"
            WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
            DEPENDS "${SHADER_ABSOLUTE}"
            COMMENT "Generating ${INC_FILE} from ${SHADER}"
         )
      else()
         if( EXISTS "${INC_FILE_ABSOLUTE}")
            message( STATUS "Keeping old ${INC_FILE} as mulle-c-string-escape is not installed")
         else()
            message( FATAL "Install mulle-c-string-escape or glslangValidator")
         endif()
      endif()
   endif()
   list( APPEND INC_FILES "${INC_FILE_ABSOLUTE}")
endforeach()


add_custom_target( "shaders"
   DEPENDS ${INC_FILES}
   COMMENT "Target to build shaders"
)

# not sure why this dont work on my mac, but its not super important
if( NOT APPLE)
   set_source_files_properties( "src/main-shader.m"
                              PROPERTIES OBJECT_DEPENDS "${INC_FILES}")
endif()


include( Dependencies OPTIONAL)

foreach( MAIN_SOURCE ${SOURCES})
   # get rid off src/main- prefix and .m suffix
   #             offset 9  length -9 - 2
   if( MAIN_SOURCE MATCHES "^src/main-")
      string( LENGTH "${MAIN_SOURCE}" MAIN_SOURCE_LENGTH)
      math( EXPR MAIN_SOURCE_LENGTH "${MAIN_SOURCE_LENGTH} - 11")
      string( SUBSTRING "${MAIN_SOURCE}" 9 ${MAIN_SOURCE_LENGTH} EXECUTABLE_NAME)

   #   set( OTHER_EXECUTABLE_OBJECT_FILES $<TARGET_OBJECTS:MulleUI>)

      set( SOURCES "${MAIN_SOURCE}")
      include( Executable)
      if( "${EXECUTABLE_NAME}" STREQUAL "shader")
         add_dependencies( "${EXECUTABLE_COMPILE_TARGET}" "shaders")
      endif()

      include( InstallExecutable)
      include( FinalOutput OPTIONAL)
   # only for Executable
      include( Motd OPTIONAL)
   endif()

endforeach()
