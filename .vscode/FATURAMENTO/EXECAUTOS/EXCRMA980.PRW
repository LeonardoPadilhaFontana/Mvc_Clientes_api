#Include "protheus.ch"



function EXCRMA980(aSA1Auto, nOpcAuto)
    
    MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto, aAI0Auto)
 
    If lMsErroAuto 
        lRet := lMsErroAuto
        MostraErro() // Não funciona na execução via JOB
    Else
        Conout("Cliente incluído com sucesso!")
    EndIf
    
return
