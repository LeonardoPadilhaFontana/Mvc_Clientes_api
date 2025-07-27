//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

 /*/{Protheus.doc} MVC001
    (Funcao definida para atualizar cadastro de clientes utilizando o cep com chamada de rest modelo 2)
    @type  Function
    @author Leonardo Padilha Fontana
    @since 25/07/2025
    @version 12.1.2410
    @param nil, nil, nil
    @return nil, nil, Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MVC001()
    // tela com os componentes
    local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("SA1")
    oBrowse:SetDescription("Cadastro de Clientes")
    oBrowse:SetOnlyFields( { "A1_COD", "A1_LOJA", "A1_NOME", "A1_CEP", "A1_EST", "A1_MUN","A1_END","A1_BAIRRO","A1_COMPLEM" } ) 
    oBrowse:Activate()

Return

/*/{Protheus.doc} ModelDef
    modelo de dados 
    @see (links_or_references)
    /*/
Static Function ModelDef()
    // local aStruSA1 := FwFormStruct(1, 'SA1')
    Local oStruSA1 := FWFormStruct( 1, 'SA1', { |x| ALLTRIM(x) $ 'A1_COD,A1_LOJA,A1_NOME,A1_CEP,A1_EST,A1_MUN,A1_END,A1_BAIRRO,A1_COMPLEM' })
    
    local oModel
    // tabela + MODEL
    
    oModel := MPFormModel():New("SA1MODEL")
    oModel:AddFields('SA1MASTER',/*cOwner*/, oStruSA1)
    oModel:setDescription("Modelo do Cadastro de Clientes")
    oModel:GetModel('SA1MASTER'):setDescription("Dados do Cliente")

Return oModel

/*/{Protheus.doc} ViewDef
    Interface do usuario 
    @see (links_or_references)
    /*/
Static Function ViewDef()
    // Nome da user function principal
    local oModel := FWLoadModel("MVC001")
    // local aStruSA1 := FwFormStruct(2, 'SA1')
    Local oStruSA1 := FWFormStruct( 2, 'SA1', { |x| ALLTRIM(x) $ 'A1_COD,A1_LOJA,A1_NOME,A1_CEP,A1_EST,A1_MUN,A1_END,A1_BAIRRO,A1_COMPLEM' })
    local oView

    oView := FWFormView():New()
    oView:setModel(oModel)
    oView:AddField('VIEW_SA1', oStruSA1, 'SA1MASTER')
    oView:CreateHorizontalBox('TELA', 100)
    oView:SetOwnerView('VIEW_SA1', 'TELA')

return oView

/*/{Protheus.doc} MenuDef
    menu de operacoes
    @see (links_or_references)
    /*/
Static Function MenuDef()
    
    local aRotina := {}
    ADD OPTION aRotina Title 'Visualizar'                         Action 'VIEWDEF.MVC001' OPERATION 2 ACCESS 1
    ADD OPTION aRotina Title 'Legendas'                           Action 'VIEWDEF.MVC001' OPERATION 2 ACCESS 1
    ADD OPTION aRotina Title 'Atualizar Endereco por CEP'         action 'u_atCliCep()'   OPERATION 0 ACCESS 0
    ADD OPTION aRotina Title 'Atualizar Endereco via CSV'         action 'u_impCli()'     OPERATION 0 ACCESS 0

return aRotina

/*/{Protheus.doc} atCliCep
    (Funcao que pega o cadastro do cliente em foco e atualiza o endereco utilizando a resposta da api viacep)    
    /*/
User Function atCliCep()
Local lRet := .T.
local aDadosEnd := {}
local aSA1Auto := {}
local nOpcAuto := 4
private lMsErroAuto := .F.
    IF SA1->A1_CEP == ''
        FWAlertError('Cliente sem CEP apontado.','Erro')
        return
    endif
        
    aDadosEnd := u_WSR001(SA1->A1_CEP)
    IF Empty(aDadosEnd) .or. empty(aDadosEnd[1])
        FWAlertError("O CEP informado no cadastro de cliente não consta na base de dados da consulta pública.",'Erro')
        return
    ENDIF

    aAdd(aSA1Auto,{"A1_COD"    , SA1->A1_COD ,Nil}) // Codigo
    aAdd(aSA1Auto,{"A1_LOJA"   , SA1->A1_LOJA ,Nil}) // Loja
    aAdd(aSA1Auto,{"A1_END"   ,  aDadosEnd[1] ,Nil}) // endereco
    aAdd(aSA1Auto,{"A1_COMPLEM", aDadosEnd[2] ,Nil}) // complemento
    aAdd(aSA1Auto,{"A1_BAIRRO",  aDadosEnd[3] ,Nil}) // bairro
    aAdd(aSA1Auto,{"A1_MUN"   ,  aDadosEnd[4] ,Nil}) // municipio
    aAdd(aSA1Auto,{"A1_EST"    , aDadosEnd[5] ,Nil}) // Estado
        
    MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto)

    if lMsErroAuto 
        lRet := lMsErroAuto
        MostraErro()
    else
        Conout("Cliente atualizado com sucesso!")
    endif

return lRet
 
/*/{Protheus.doc} User Function impCli
funcao para ler arquivo csv com separador de campos em ;
, validar os dados se existem e alterar caso encontrados
/*/
 
User Function impCli()
    Local aArea := FWGetArea()
    Local cArquivo := "C:\importador\clientes.txt"
    Local oFile
    local aLinAtu := {}
    local aSA1Auto := {}
    local nTotLinhas := 0
    private lMsErroAuto := .F.
 
 
    //Se o arquivo existir
    If File(cArquivo)
 
        //Tenta abrir o arquivo e pegar o conteudo
        oFile := FwFileReader():New(cArquivo)
        If oFile:Open()
  
            //Pegando o total de linhas
            aLinhas := oFile:GetAllLines()
            nTotLinhas := Len(aLinhas)
            nLinhaAtu := 0
        
            oFile:Close()
            oFile := FWFileReader():New(cArquivo)
            oFile:Open()
 
            //Enquanto tiver linhas
            While (oFile:HasLine())
                nLinhaAtu++
 
                //Pega a linha atual e exibe
                cLinAtu := oFile:GetLine()
                aLinAtu := StrTokArr( cLinAtu, ";" )
                lValLinhas := fValidaLinha(aLinAtu)
                //Se a linha for valida, atualiza o cliente
                if lValLinhas                
                    //Se encontrou o cliente, atualiza os dados                    
                    aAdd(aSA1Auto,{"A1_COD"    , aLinAtu[1] ,Nil}) // Codigo
                    aAdd(aSA1Auto,{"A1_LOJA"   , aLinAtu[2] ,Nil}) // Loja
                    aAdd(aSA1Auto,{"A1_CEP"    , aLinAtu[3] ,Nil}) // Cep
                    aAdd(aSA1Auto,{"A1_END"   ,  aLinAtu[4] ,Nil}) // endereco
                    aAdd(aSA1Auto,{"A1_COMPLEM", aLinAtu[5] ,Nil}) // complemento
                    aAdd(aSA1Auto,{"A1_BAIRRO",  aLinAtu[6] ,Nil}) // bairro
                    aAdd(aSA1Auto,{"A1_MUN"   ,  aLinAtu[7] ,Nil}) // municipio
                    aAdd(aSA1Auto,{"A1_EST"    , aLinAtu[8] ,Nil}) // Estado

                    MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, 4)
                    IF lMsErroAuto
                        ConOut("Erro ao atualizar cliente: " + cLinAtu[1] + " - " + cLinAtu[2] + ' na linha ' + nLinhaAtu)
                    endif
                ENDIF
            EndDo
        EndIf
        oFile:Close()
    else
        FWAlertError("Arquivo não encontrado: " + cArquivo, "Erro")
    EndIf
 
    FWRestArea(aArea)
Return

static function fValidaLinha(aLinAtu)
local aArea := FWGetArea()
local aAreaSA1 := FWGetArea("SA1")
local lRet := .T.
    
    // valida se a array tem o tamanho correto
    if Len(aLinAtu) != 8
        conout('Linha inválida: ' + Str(aLinAtu))
        lRet := .F.
    return lRet
    
    // Validar se os campos obrigatórios estão preenchidos
    if Empty(aLinAtu[1]) .or. Empty(aLinAtu[2]) .or. Empty(aLinAtu[3]) .or. Empty(aLinAtu[4]) .or.;
        Empty(aLinAtu[5]) .or. Empty(aLinAtu[6]) .or. Empty(aLinAtu[7]) .or. Empty(aLinAtu[8])
        conout('Campos obrigatórios não preenchidos para o cliente: ' + aLinAtu[1] + ' - ' + aLinAtu[2])
        lRet := .F.
    endif
    // Validar se o cliente existe
    SA1->(DBSetOrder(1))
    if !SA1->(DBSeek(xFilial('SA1')+aLinAtu[1]+aLinAtu[2]))
        Conout("Cliente nao encontrado: " + aLinAtu[1] + " - " + aLinAtu[2])
        lRet := .F.
    endif
    // Validar se o CEP é válido
    if empty(U_WSR001(aLinAtu[3]))
        conout('CEP inválido para o cliente: ' + aLinAtu[1] + ' - ' + aLinAtu[2])
        lRet := .F.
    Endif
fwRestArea(aArea)
fwRestArea(aAreaSA1)

return lRet
