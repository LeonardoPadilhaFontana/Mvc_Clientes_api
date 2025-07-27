#include "tlpp-core.th"
#include "tlpp-rest.th"
#include "restful.ch"
#include "totvs.ch"

WSRESTFUL PING DESCRIPTION "Teste REST básico" FORMAT APPLICATION_JSON

    WSMETHOD GET Hello
        DESCRIPTION "Hello World REST"
        WSSYNTAX "/PING"
        PATH "/PING"
        PRODUCES AS CHARACTER
    ENDMETHOD

END WSRESTFUL

User Function Hello()
    Return '{"mensagem":"Hello World"}'
