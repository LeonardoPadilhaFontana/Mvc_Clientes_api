#include "tlpp-core.th"
#include "tlpp-rest.th"
#include "restful.ch"
#include "totvs.ch"

// Bloco de definição da API REST
WSRESTFUL WSCLIENTES DESCRIPTION "API REST para atualizar cliente" FORMAT APPLICATION_JSON

    WSMETHOD POST AtualizarCliente
        DESCRIPTION "Atualiza cliente do cadastro SA1"
        WSSYNTAX "/WSCLIENTES"
        PATH "/WSCLIENTES"
        PRODUCES AS CHARACTER
    ENDMETHOD

END WSRESTFUL

// Implementação da função ADVPL
User Function AtualizarCliente()
    Local cConteudo := Self:GetContent()
    Local oJson     := JsonObject():New()
    Local aSA1Auto  := {}
    Local cResponse := ""
    Private lMsErroAuto := .F.

    // Validação do JSON recebido
    If !Empty(oJson:FromJson(cConteudo))
        SetRestFault(400, "JSON inválido.")
        Return '{"erro":"JSON inválido."}'
    EndIf

    // Verificação de campos obrigatórios
    If Empty(oJson["A1_COD"]) .Or. Empty(oJson["A1_LOJA"])
        SetRestFault(400, "A1_COD e A1_LOJA são obrigatórios.")
        Return '{"erro":"A1_COD e A1_LOJA são obrigatórios."}'
    EndIf

    // Verifica se o cliente existe
    dbSelectArea("SA1")
    dbSetOrder(1) // Índice por A1_COD + A1_LOJA
    If SA1->(dbSeek(xFilial("SA1") + oJson["A1_COD"] + oJson["A1_LOJA"]))

        aAdd(aSA1Auto, {"A1_COD",     oJson["A1_COD"], Nil})
        aAdd(aSA1Auto, {"A1_LOJA",    oJson["A1_LOJA"], Nil})
        aAdd(aSA1Auto, {"A1_END",     oJson["A1_END"], Nil})
        aAdd(aSA1Auto, {"A1_CEP",     oJson["A1_CEP"], Nil})
        aAdd(aSA1Auto, {"A1_BAIRRO",  oJson["A1_BAIRRO"], Nil})
        aAdd(aSA1Auto, {"A1_COMPLEM", oJson["A1_COMPLEM"], Nil})
        aAdd(aSA1Auto, {"A1_MUN",     oJson["A1_MUN"], Nil})
        aAdd(aSA1Auto, {"A1_EST",     oJson["A1_EST"], Nil})

        // Atualiza o cliente
        MSExecAuto({|a, b, c| CRMA980(a, b, c)}, aSA1Auto, 4)

        If lMsErroAuto
            SetRestFault(402, "Nao foi possivel alterar o cadastro do cliente.")    
            Return cResponse
        EndIf

        SetResponse(200, {"setResponse":"Cliente atualizado com sucesso."})
    Else
        SetRestFault(404, "Cliente não encontrado.")
    EndIf

Return cResponse
