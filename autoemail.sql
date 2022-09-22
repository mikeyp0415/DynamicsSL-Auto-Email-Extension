
DECLARE @EmailHey VARCHAR(50) -- database name 

DECLARE db_cursor CURSOR FOR 
select DISTINCT
SLApplication..PJADDR.email
from SLApplication..QQInvoiceInquiry
join SLApplication..PAProjectList on SLApplication..PAProjectList.Project=SLApplication..QQInvoiceInquiry.ProjectID
join SLApplication..PJADDR on SLApplication..PJADDR.addr_key=SLApplication..QQInvoiceInquiry.ProjectID
join SLApplication..xvACGProjKeyData on SLApplication..xvACGProjKeyData.project=SLApplication..QQInvoiceInquiry.ProjectID
where SLApplication..QQInvoiceInquiry.Cury_Amount > 0
and SLApplication..QQInvoiceInquiry.DocDate > '2020'
and SLApplication..QQInvoiceInquiry.DocDate < DATEADD(day,-90,GETDATE())
and SLApplication..PAProjectList.Project in (select ProjectID from SLApplication..QQInvoiceInquiry)
and SLApplication..QQInvoiceInquiry.Refnbr not in (select refnbr from SLApplication..xvrACGPaidInvoices)
and SLApplication..PJADDR.addr_type_cd in ('C1','C2')
and SLApplication..PJADDR.email != ''
and SLApplication..PJADDR.individual != ''

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @EmailHey 

WHILE @@FETCH_STATUS = 0  
BEGIN  
DECLARE @trigger NVARCHAR(MAX);
SET @trigger = (STUFF((SELECT DISTINCT ';' + 
				SLApplication..PJADDR.email
				FROM SLApplication..PJADDR
				WHERE email = @EmailHey
				FOR XML PATH('')),1,1,''));



DECLARE @triggername NVARCHAR(MAX);
SET @triggername = (STUFF((SELECT DISTINCT ';' + 
				SLApplication..PJADDR.individual
				FROM SLApplication..PJADDR
				WHERE SLApplication..PJADDR.email = @trigger
				FOR XML PATH('')),1,1,''));
				

DECLARE @Addr NVARCHAR(MAX);
SET @Addr = (STUFF((select TOP 1 ';' + 
SLApplication..xvACGProjKeyData.ProjectSite
from SLApplication..QQInvoiceInquiry
join SLApplication..PAProjectList on SLApplication..PAProjectList.Project=SLApplication..QQInvoiceInquiry.ProjectID
join SLApplication..PJADDR on SLApplication..PJADDR.addr_key=SLApplication..QQInvoiceInquiry.ProjectID
join SLApplication..xvACGProjKeyData on SLApplication..xvACGProjKeyData.project=SLApplication..QQInvoiceInquiry.ProjectID
where SLApplication..QQInvoiceInquiry.Cury_Amount > 0
and SLApplication..QQInvoiceInquiry.DocDate > '2020'
and SLApplication..QQInvoiceInquiry.DocDate < DATEADD(day,-90,GETDATE())
and SLApplication..PAProjectList.Project in (select ProjectID from SLApplication..QQInvoiceInquiry)
and SLApplication..QQInvoiceInquiry.Refnbr not in (select refnbr from SLApplication..xvrACGPaidInvoices)
and SLApplication..PJADDR.addr_type_cd in ('C1','C2')
and SLApplication..PJADDR.individual = @triggername

				FOR XML PATH('')),1,1,''));

DECLARE @AddrSubject NVARCHAR(MAX);
SET @AddrSubject = '(L+M) UNPAID INVOICES FOR:' + @Addr + '';

DECLARE @body_content nvarchar(max);
SET @body_content = N'
<style>
table.GeneratedTable {
  width: 100%;
  background-color: #ffffff;
  border-collapse: collapse;
  border-width: 2px;
  border-color: #ffcc00;
  border-style: solid;
  color: #000000;
}

#red {
color: red;
}

table.GeneratedTable td, table.GeneratedTable th {
  border-width: 2px;
  border-color: #ffcc00;
  border-style: solid;
  padding: 3px;
}

table.GeneratedTable thead {
  background-color: #ffcc00;
}
</style>

<center><img src="https://i.ibb.co/fnbB8q7/download.png"></center>
<br>
<br>

<h1 id="red">NOTICE: We are in the process of launching or new automatic Email system to help streamline the flow of information. We apologize if this email was sent to the wrong person or contains wrong information in any way. If so, please reply and inform us so we can update this information.</strong> </h1>

 <br>

<h1>PLEASE BE ADVISED</h1> 

<p>There are unpaid invoices for <strong>' + @Addr + '</strong> which have been outstanding for 90 days or more. <br> See below for a list of charges:</p> <br>

<br>

<table class="GeneratedTable">
  <thead>
    <tr>
      <th>INVOICE #</th>
      <th>INVOICE DATE</th>
      <th>DESCRIPTION</th>
	  <th>ADDRESS</th>
	  <th>COMPANY</th>
	  <th>INVOICE AMOUNT</th>
	  <th>INDIVIDUAL</th>
    </tr>
  </thead>
  <tbody>
 ' +
CAST(
        (select
td = SLApplication..QQInvoiceInquiry.RefNbr, '',
td = cast(SLApplication..QQInvoiceInquiry.DocDate as date), '',
td = SLApplication..PAProjectList.Description, '',
td = SLApplication..xvACGProjKeyData.ProjectSite, '',
td = SLApplication..QQInvoiceInquiry.Name, '',
td = cast(SLApplication..QQInvoiceInquiry.Cury_Amount as numeric(9,2)), '',
td = SLApplication..PJADDR.individual, ''
from SLApplication..QQInvoiceInquiry
join SLApplication..PAProjectList on SLApplication..PAProjectList.Project=SLApplication..QQInvoiceInquiry.ProjectID
join SLApplication..PJADDR on SLApplication..PJADDR.addr_key=SLApplication..QQInvoiceInquiry.ProjectID
join SLApplication..xvACGProjKeyData on SLApplication..xvACGProjKeyData.project=SLApplication..QQInvoiceInquiry.ProjectID
where SLApplication..QQInvoiceInquiry.Cury_Amount > 0
and SLApplication..QQInvoiceInquiry.DocDate > '2020'
and SLApplication..QQInvoiceInquiry.DocDate < DATEADD(day,-90,GETDATE())
and SLApplication..PAProjectList.Project in (select ProjectID from SLApplication..QQInvoiceInquiry)
and SLApplication..QQInvoiceInquiry.Refnbr not in (select refnbr from SLApplication..xvrACGPaidInvoices)
and SLApplication..PJADDR.addr_type_cd in ('C1','C2')
and SLApplication..PJADDR.individual = @triggername
        FOR XML PATH('tr'), TYPE   
        ) AS nvarchar(max)
    ) +
  N'</tbody>
</table>

 <br>
  <p>For more information, or to pay an invoice please contact <strong>Tessa Phillips, Accounts Receivable Specialist:</strong><br>
	<strong>Email:</strong> tessap@lawlessmangione.com<br><strong>Phone:</strong> 914.349.6723 </p>
  ';

EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'L+M_Reminders',
    @recipients = @trigger,
	@blind_copy_recipients = 'ADD YOUR EMAIL HERE OPTIONALLY',
    @body = @body_content,
    @body_format = 'HTML',
    @subject = @AddrSubject;
FETCH NEXT FROM db_cursor INTO @EmailHey 
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 