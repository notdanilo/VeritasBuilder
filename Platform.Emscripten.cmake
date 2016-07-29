FUNCTION(VERITAS_EMSCRIPTEN_ADD_EXECUTABLE TARGET)
        FILE(WRITE "${CMAKE_BINARY_DIR}/${TARGET}.html"
            "<html>\
                <body style=\"margin:0\">\
                    <script src=\"${TARGET}.js\"></script>\
                </body>\
            </html>"
        )
ENDFUNCTION()
