unit RenanUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Grids, DBGrids, Math;

type
  TForm1 = class(TForm)
    ADOConnection1: TADOConnection;
    Button1: TButton;
    ADOQuery1: TADOQuery;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    ADOTable1: TADOTable;
    ADOQuery2: TADOQuery;
    Button2: TButton;
    DBGrid2: TDBGrid;
    ADOTable2: TADOTable;
    DataSource2: TDataSource;
    ADOTable1Invoice_Number: TIntegerField;
    ADOTable1Customer_Id: TStringField;
    ADOTable1Invoice_Date: TDateTimeField;
    ADOTable1Payment_Term_Id: TStringField;
    ADOTable1Due_Date: TDateTimeField;
    ADOTable1Net_Amount: TFloatField;
    ADOTable1VAT_Amount: TFloatField;
    ADOTable1Total_Amount: TFloatField;
    ADOTable2Invoice_Number: TIntegerField;
    ADOTable2Line_Number: TIntegerField;
    ADOTable2Area_Code: TStringField;
    ADOTable2Number_of_Calls: TIntegerField;
    ADOTable2Duration: TFloatField;
    ADOTable2Rate: TFloatField;
    ADOTable2Line_Amount: TFloatField;
    procedure Button1Click(Sender: TObject);
    procedure RemoveDuplicated();
    procedure ConvertInput();
    procedure Button2Click(Sender: TObject);
    function calculateTotalInvoice(customer_id: string; month,year: integer) : double;
  private
    numberOfClicks: Integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses DateUtils;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  nameInputFile: String;
  myFile : TextFile;
  line : String;
  Parts : TStringList;
  i : Integer;
begin
  nameInputFile := inputbox('Input File','Insert the name of the input file (with extension)'#13#10#13#10'For example: Input.txt'#13#10#13#10'The file should be inside the folder project','');
  // Test if the user typed some value or if clicked the cancel button
  if nameInputFile <> '' then
  begin
    Inc(numberOfClicks);
    AssignFile(myFile,nameInputFile);
    Reset(myFile);
    // Check if its the first time click the button to import Data, create ##temp only 1 time
    if numberOfClicks = 1 then
    begin
      ADOQuery1.SQL.Clear;
      ADOQuery1.SQL.Add('CREATE TABLE ##temp (Customer_Id varchar(12), Call_Date date, Call_Time time,');
      ADOQuery1.SQL.Add('Area_Code varchar(12), Duration int) ');
      ADOQuery1.ExecSQL;
    end;
    // Starts to read the file and insert into ##temp
    while not Eof(myFile) do
    begin
      ReadLn(myFile, line);
      Parts := TStringList.Create;
      try
        Parts.Clear;
        ExtractStrings([';'],[], PChar(line), Parts);   // Separate input

        ADOQuery1.SQL.Clear;
        ADOQuery1.SQL.Add('INSERT INTO ##temp VALUES (');  // Insert into ##temp table
        ADOQuery1.SQL.Add(''''+Parts[0]+''','''+Parts[1]+''','''+Parts[2]+''','''+Parts[3]+''','''+Parts[4]+''')');
        ADOQuery1.ExecSQL;

      finally
        Parts.Free;
      end;
    end;

    RemoveDuplicated(); // Call procedure to delete if some line of the input is equal
    ConvertInput(); // Call procedure to Convert and Insert from ##temp into imported_calls
    CloseFile(myFile);
    ShowMessage('Data Imported');
  end // end of the IF of the button
  else  // in case the user entered nothing as the input or canceled
    ShowMessage('Imported Failed');
end;

procedure TForm1.RemoveDuplicated();
begin
  ADOQuery1.SQL.Clear; // Basicly select distinct to new table then drop old table, copy new table to old table and drop new table
  ADOQuery1.SQL.Add('SELECT DISTINCT Customer_Id,Call_Date,Call_Time,Area_Code,Duration INTO ##temp2 from ##temp');
  ADOQuery1.SQL.Add('DROP table ##temp');
  ADOQuery1.SQL.Add('SELECT * INTO ##temp FROM ##temp2');
  ADOQuery1.SQL.Add('DROP TABLE ##temp2');
  ADOQuery1.ExecSQL;
end;

procedure TForm1.ConvertInput();
var
Customer_Id,Call_Date,Call_Time,Area_Code,aux: String;
Year,Month: Integer;
Call_Duration,existsCustomer: Integer;
Parts : TStringList;
Call_Duration_Min: double;
begin
  ADOQuery1.SQL.Clear;
  ADOQuery1.SQL.Add('SELECT * FROM ##temp');
  ADOQuery1.Open;
  while not ADOQuery1.Eof do
  begin
    // Transform and insert the data from temporary table into imported_calls table

    // Transform duration of call in minutes
    Call_Duration := ADOQuery1.FieldByName('Duration').AsInteger;
    Call_Duration_Min := Call_Duration / 60;
    DecimalSeparator := '.';
    Call_Duration_Min := RoundTo(Call_Duration_Min, -2);
    aux := FloatToStr(Call_Duration_Min);
    
    Customer_Id := ADOQuery1.FieldByName('Customer_Id').AsString;
    // Check if Customer_Id exists on the DB
    ADOQuery2.SQL.Clear;
    ADOQuery2.SQL.Add('SELECT COUNT(1) AS temp FROM customers WHERE Customer_Id =');
    ADOQuery2.SQL.Add(''''+Customer_Id+'''');
    ADOQuery2.Open;
    existsCustomer := ADOQuery2.FieldByName('temp').AsInteger;
    if existsCustomer = 0 then
    begin
      Customer_Id := '*'; // If doesnt exist, will receive *
    end;


    // Transform the time: trim some 0s in the end
    Call_Time := ADOQuery1.FieldByName('Call_Time').AsString;
    Parts := TStringList.Create;
    Parts.Clear;
    ExtractStrings(['.'],[], PChar(Call_Time), Parts);
    Call_Time := Parts[0];
    Parts.Clear;

    // Transform the date: get the year and month separated
    Call_Date := ADOQuery1.FieldByName('Call_Date').AsString;
    ExtractStrings(['-'],[], PChar(Call_Date), Parts);
    Year := StrToInt(Parts[0]);
    Month := StrToInt(Parts[1]);

    Area_Code := ADOQuery1.FieldByName('Area_Code').AsString;

    //Insert into imported_calls all the information of some row
    ADOQuery2.SQL.Clear;
    ADOQuery2.SQL.Add('INSERT INTO imported_calls (Customer_Id,Call_Date_Time,Area_Code,Year,Month,Call_Duration) VALUES ('''+Customer_Id+''','''+Call_Date+'T'+Call_Time+''','''+Area_Code+''','+IntToStr(Year)+','+IntToStr(Month)+','+aux+')');
    ADOQuery2.ExecSQL;

    ADOQuery1.Next;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  input1,input2,Payment_Term_Id,Area_Code,customer: string;
  year,month,invoiceNumber,i,days_due,existsArea,numberLine,numberOfInvoicesGenerated: Integer;
  listOfCustomers: TStringList;
  invoiceDate,due_date,invoiced: TDateTime;
  call_duration,rate,net_amount,vat_amount,total_amount: double;
begin
  DecimalSeparator := '.';
  // Input the month and year that will create the invoices
  input1 := inputbox('Month','Insert the month (number) of the invoice','');
  input2 := inputbox('Year','Insert the year of the invoice','');

  try
    month := StrToInt(input1);
  except
    on E : EConvertError do
    begin
      ShowMessage('Month invalid !!!'#13#10'Exception message = '+E.Message);
     end;
  end;

  try
    year := StrToInt(input2);
  except
    on E : EConvertError do
    begin
      ShowMessage('Year invalid !!!'#13#10'Exception message = '+E.Message);
     end;
  end;

  // Select to get all the customers with possible invoices
  ADOQuery1.SQL.Clear;
  ADOQuery1.SQL.Add('SELECT DISTINCT Customer_Id FROM imported_calls WHERE ((Month <=');
  ADOQuery1.SQL.Add(IntToStr(month)+' AND Year = '+IntToStr(year)+') OR (Year < '+IntToStr(year)+')) AND Invoiced IS NULL');
  ADOQuery1.Open;
  listOfCustomers := TStringList.Create;
  listOfCustomers.Clear;
  while not ADOQuery1.Eof do
  begin
    customer := ADOQuery1.FieldByName('Customer_Id').AsString;
    // Check if the customer isnt * , wont generate invoices for unknow Customers.
    // Add all other customers inside a list
    if customer <> '*' then
    begin
      listOfCustomers.Add(customer);
    end;
    ADOQuery1.Next;
  end;

  // Iteration throught all Customers that will generate the invoices of selected month
  for i:=0 to listOfCustomers.Count-1 do
  begin
    // First of all, check if the total amount will be more than 1 EUR, because if it's not
    // then there is no need to even generate the invoice
    net_amount := calculateTotalInvoice(listOfCustomers[i],month,year); // Calculate the total invoice

    if net_amount >= 1 then  // If the total value of the invoice with VAT was bigger than 0.99 EUR then create the invoice
    begin
      // Get the last number of invoice in the table invoice headers, and set the next invoice number
      ADOQuery1.SQL.Clear;
      ADOQuery1.SQL.Add('SELECT TOP 1 Invoice_Number FROM invoice_headers ORDER BY invoice_number DESC');
      ADOQuery1.Open;
      ADOQuery1.FieldByName('Invoice_Number').AsInteger;
      invoiceNumber := ADOQuery1.FieldByName('Invoice_Number').AsInteger+1;

      //Invoice Date should be the last day of the month
      invoiceDate := EndOfAMonth(year,month);

      // Get the Payment term of some customer
      ADOQuery1.SQL.Clear;
      ADOQuery1.SQL.Add('SELECT Payment_Term_Id FROM customers WHERE Customer_Id =');
      ADOQuery1.SQL.Add(''''+listOfCustomers[i]+'''');
      ADOQuery1.Open;
      Payment_Term_Id := ADOQuery1.FieldByName('Payment_Term_Id').AsString;


      // Get the days due and the due date of the invoice
      ADOQuery1.SQL.Clear;
      ADOQuery1.SQL.Add('SELECT Days_Due FROM payment_terms WHERE Payment_Term_Id = ');
      ADOQuery1.SQL.Add(''''+Payment_Term_Id+'''');
      ADOQuery1.Open;
      days_due := ADOQuery1.FieldByName('Days_Due').AsInteger;
      due_date := IncDay(invoiceDate,days_due);


      // Create the invoice = Insert into table invoice_headers
      ADOQuery1.SQL.Clear;
      ADOQuery1.SQL.Add('INSERT INTO invoice_headers (Invoice_Number,Customer_Id,Invoice_Date,Payment_Term_Id,Due_Date) VALUES (');
      ADOQuery1.SQL.Add(IntToStr(invoiceNumber)+','''+listOfCustomers[i]+''','''+FormatDateTime('YYYYMMDD',invoiceDate)+''','''+Payment_Term_Id+''','''+FormatDateTime('YYYYMMDD',due_date)+''')');
      ADOQuery1.ExecSQL;

      // Select all calls of the customer, where is not invoiced yet until the selected month
      ADOQuery1.SQL.Clear;
      ADOQuery1.SQL.Add('SELECT * FROM imported_calls WHERE Customer_Id =');
      ADOQuery1.SQL.Add(''''+listOfCustomers[i]+''' AND ( (Month <='+IntToStr(month)+' AND Year = '+IntToStr(year)+') OR (Year < '+IntToStr(year)+')) AND Invoiced IS NULL');
      ADOQuery1.Open;
      net_amount := 0;
      numberLine := 1;
      // For each row (call) calculate the amount value and join all calls of same area
      while not ADOQuery1.Eof do
      begin

        // Get the Area Code
        Area_Code := ADOQuery1.FieldByName('Area_Code').AsString;

        // Get the Rate of an Area Code
        ADOQuery2.SQL.Clear;
        ADOQuery2.SQL.Add('SELECT Rate FROM call_rates WHERE Area_Code = '+''+Area_Code+'');
        ADOQuery2.Open;
        rate := ADOQuery2.FieldByName('Rate').AsFloat;

        // Get the Call duration
        call_duration:= ADOQuery1.FieldByName('Call_Duration').AsFloat;

        // Calculate the net amount: Call duration x Rate
        net_amount := net_amount + (call_duration * rate);


        // Check if the area already exists
        ADOQuery2.SQL.Clear;
        ADOQuery2.SQL.Add('SELECT COUNT(1) AS temp FROM invoice_lines WHERE Invoice_Number =');
        ADOQuery2.SQL.Add(IntToStr(invoiceNumber)+' AND Area_Code = '''+Area_Code+'''');
        ADOQuery2.Open;
        existsArea := ADOQuery2.FieldByName('temp').AsInteger;
       

        case existsArea of
        0: // in case the area doesnt exist yet, start new line
          begin
            ADOQuery2.SQL.Clear;
            ADOQuery2.SQL.Add('INSERT INTO invoice_lines VALUES(');
            ADOQuery2.SQL.Add(IntToStr(invoiceNumber)+','+IntToStr(numberLine)+','''+Area_Code+''',1,'+FloatToStr(call_duration)+','+FloatToStr(rate)+','+FloatToStr(call_duration*rate)+')');
            ADOQuery2.ExecSQL;
            numberLine := numberLine +1;
          end;
        1: // in case the area exists, then accumulate on the same line
          begin
            ADOQuery2.SQL.Clear;
            ADOQuery2.SQL.Add('UPDATE invoice_lines SET Number_of_Calls = Number_of_Calls + 1 , Duration = Duration + ');
            ADOQuery2.SQL.Add(FloatToStr(call_duration)+' , Line_Amount = Line_Amount + '+FloatToStr(rate*call_duration)+' WHERE Invoice_Number = ');
            ADOQuery2.SQL.Add(IntToStr(invoiceNumber)+' AND Area_Code = '''+Area_Code+'''');
            ADOQuery2.ExecSQL;
          end;
        end;

        ADOQuery1.Next;
      end;

      // Update the values of the amounts
      vat_amount := net_amount * 0.2;
  
      total_amount := net_amount + vat_amount;
      // Update the invoice headers with the amounts
      ADOQuery1.SQL.Clear;
      ADOQuery1.SQL.Add('UPDATE invoice_headers SET Net_Amount = ');
      ADOQuery1.SQL.Add(FloatToStr(net_amount)+' , Vat_Amount = '+FloatToStr(vat_amount)+', Total_Amount =');
      ADOQuery1.SQL.Add(FloatToStr(total_amount)+' WHERE Invoice_Number = '+IntToStr(invoiceNumber));
      ADOQuery1.ExecSQL;

      // Increase the number of invoice generated, this variable is only used in the output message
      Inc(numberOfInvoicesGenerated);

      // Mark the invoice with the current datetime
      invoiced := Now;
      ADOQuery1.SQL.Clear;
      ADOQuery1.SQL.Add('UPDATE imported_calls SET Invoiced = ');
      ADOQuery1.SQL.Add(''''+FormatDateTime('YYYYMMDD hh:nn:ss',invoiced)+''' WHERE Customer_Id = ');
      ADOQuery1.SQL.Add(''''+listOfCustomers[i]+''' AND ( (Month <='+IntToStr(month)+' AND Year = '+IntToStr(year)+') OR (Year < '+IntToStr(year)+')) AND Invoiced IS NULL');
      ADOQuery1.ExecSQL;
    end;
  end;
  if numberOfInvoicesGenerated = 0 then
  ShowMessage('None invoice was generated');
  if numberOfInvoicesGenerated = 1 then
  ShowMessage(IntToStr(numberOfInvoicesGenerated)+' Invoice Generated');
  if numberOfInvoicesGenerated > 1 then
  ShowMessage(IntToStr(numberOfInvoicesGenerated)+' Invoices Generated');

  // Refresh the Grids
  DBGrid1.DataSource.DataSet.Close;
  DBGrid1.DataSource.DataSet.Open;
  DBGrid2.DataSource.DataSet.Close;
  DBGrid2.DataSource.DataSet.Open;
end;

function TForm1.calculateTotalInvoice(customer_id: string; month,year: integer): double;
var
net_amount,rate,call_duration: double;
area_code: string;
begin
  // Select all calls of the customer, where is not invoiced yet until the selected month
  ADOQuery1.SQL.Clear;
  ADOQuery1.SQL.Add('SELECT * FROM imported_calls WHERE Customer_Id =');
  ADOQuery1.SQL.Add(''''+customer_id+''' AND ( (Month <='+IntToStr(month)+' AND Year = '+IntToStr(year)+') OR (Year < '+IntToStr(year)+')) AND Invoiced IS NULL');
  ADOQuery1.Open;
  net_amount := 0;
  while not ADOQuery1.Eof do
  begin
    // Get the Area Code
    area_code := ADOQuery1.FieldByName('Area_Code').AsString;

    // Get the Rate of an Area Code
    ADOQuery2.SQL.Clear;
    ADOQuery2.SQL.Add('SELECT Rate FROM call_rates WHERE Area_Code = '+''+area_code+'');
    ADOQuery2.Open;
    rate := ADOQuery2.FieldByName('Rate').AsFloat;

    // Get the Call duration
    call_duration:= ADOQuery1.FieldByName('Call_Duration').AsFloat;

    // Calculate the net amount: Call duration x Rate
    net_amount := net_amount + (call_duration * rate);

    ADOQuery1.Next;
  end;
  Result := (net_amount * 1.2); // Result with VAT included
end;

end.
