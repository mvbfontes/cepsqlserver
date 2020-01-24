
CREATE PROCEDURE [dbo].[stpConsulta_CEP] (
    @Nr_CEP VARCHAR(20)
)
AS BEGIN
 
    DECLARE @responseText as table(responseText nvarchar(max))
	DECLARE @status int

    DECLARE 
        @obj INT,
        @Url VARCHAR(255),
        @resposta VARCHAR(8000),
        @xml XML
 
 
    -- Recupera apenas os números do CEP
    DECLARE @startingIndex INT = 0
    
    WHILE (1=1)
    BEGIN
      
        SET @startingIndex = PATINDEX('%[^0-9]%', @Nr_CEP)  
        
        IF (@startingIndex <> 0)
            SET @Nr_CEP = REPLACE(@Nr_CEP, SUBSTRING(@Nr_CEP, @startingIndex, 1), '')  
        ELSE    
            BREAK
            
    END
    
    
    
    SET @Url = 'http://viacep.com.br/ws/' + @Nr_CEP + '/xml'
 
    EXEC sys.sp_OACreate 'MSXML2.XMLHTTP', @obj OUT
    EXEC sys.sp_OAMethod @obj, 'open', NULL, 'GET', @Url, 'false'
    EXEC sys.sp_OAMethod @obj, 'send'
    EXEC sp_OAGetProperty @obj, 'status', @status OUT
    INSERT INTO @ResponseText (ResponseText) EXEC sp_OAGetProperty @obj, 'responseText'
    EXEC sys.sp_OADestroy @obj

	
	SELECT @xml = CAST(REPLACE(responseText, '<?xml version="1.0" encoding="UTF-8"?>', '') AS XML)
	FROM @responseText 
    
	
	SELECT
        @xml.value('(/xmlcep/cep)[1]', 'varchar(9)') AS CEP,
        @xml.value('(/xmlcep/logradouro)[1]', 'varchar(200)') AS Logradouro,
        @xml.value('(/xmlcep/complemento)[1]', 'varchar(200)') AS Complemento,
        @xml.value('(/xmlcep/bairro)[1]', 'varchar(200)') AS Bairro,
        @xml.value('(/xmlcep/localidade)[1]', 'varchar(200)') AS Cidade,
        @xml.value('(/xmlcep/uf)[1]', 'varchar(200)') AS UF,
        @xml.value('(/xmlcep/ibge)[1]', 'varchar(200)') AS IBGE


END


