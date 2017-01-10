object Form1: TForm1
  Left = 193
  Top = 203
  Width = 950
  Height = 485
  Caption = 'Phone Company Billing System'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 392
    Top = 40
    Width = 145
    Height = 25
    Caption = 'Import Data'
    TabOrder = 0
    OnClick = Button1Click
  end
  object DBGrid1: TDBGrid
    Left = 24
    Top = 144
    Width = 897
    Height = 137
    DataSource = DataSource1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'Invoice_Number'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Customer_Id'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Invoice_Date'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Payment_Term_Id'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Due_Date'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Net_Amount'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'VAT_Amount'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Total_Amount'
        Visible = True
      end>
  end
  object Button2: TButton
    Left = 392
    Top = 88
    Width = 145
    Height = 25
    Caption = 'Generate Monthly Invoices'
    TabOrder = 2
    OnClick = Button2Click
  end
  object DBGrid2: TDBGrid
    Left = 24
    Top = 280
    Width = 897
    Height = 161
    DataSource = DataSource2
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object ADOConnection1: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security In' +
      'fo=False;Initial Catalog=estonia;Data Source=SERIGY'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 112
    Top = 8
  end
  object ADOQuery1: TADOQuery
    Connection = ADOConnection1
    Parameters = <>
    Left = 48
    Top = 40
  end
  object DataSource1: TDataSource
    DataSet = ADOTable1
    Left = 136
    Top = 40
  end
  object ADOTable1: TADOTable
    Active = True
    Connection = ADOConnection1
    CursorType = ctStatic
    TableName = 'invoice_headers'
    Left = 104
    Top = 80
    object ADOTable1Invoice_Number: TIntegerField
      FieldName = 'Invoice_Number'
    end
    object ADOTable1Customer_Id: TStringField
      FieldName = 'Customer_Id'
      Size = 12
    end
    object ADOTable1Invoice_Date: TDateTimeField
      FieldName = 'Invoice_Date'
    end
    object ADOTable1Payment_Term_Id: TStringField
      FieldName = 'Payment_Term_Id'
      Size = 12
    end
    object ADOTable1Due_Date: TDateTimeField
      FieldName = 'Due_Date'
    end
    object ADOTable1Net_Amount: TFloatField
      FieldName = 'Net_Amount'
      DisplayFormat = '0.00'
    end
    object ADOTable1VAT_Amount: TFloatField
      FieldName = 'VAT_Amount'
      DisplayFormat = '0.00'
    end
    object ADOTable1Total_Amount: TFloatField
      FieldName = 'Total_Amount'
      DisplayFormat = '0.00'
    end
  end
  object ADOQuery2: TADOQuery
    Connection = ADOConnection1
    Parameters = <>
    Left = 80
    Top = 40
  end
  object ADOTable2: TADOTable
    Active = True
    Connection = ADOConnection1
    CursorType = ctStatic
    IndexFieldNames = 'Invoice_Number'
    MasterFields = 'Invoice_Number'
    MasterSource = DataSource1
    TableName = 'invoice_lines'
    Left = 136
    Top = 80
    object ADOTable2Invoice_Number: TIntegerField
      FieldName = 'Invoice_Number'
    end
    object ADOTable2Line_Number: TIntegerField
      FieldName = 'Line_Number'
    end
    object ADOTable2Area_Code: TStringField
      FieldName = 'Area_Code'
      Size = 12
    end
    object ADOTable2Number_of_Calls: TIntegerField
      FieldName = 'Number_of_Calls'
    end
    object ADOTable2Duration: TFloatField
      FieldName = 'Duration'
      DisplayFormat = '0.00'
    end
    object ADOTable2Rate: TFloatField
      FieldName = 'Rate'
      DisplayFormat = '0.00'
    end
    object ADOTable2Line_Amount: TFloatField
      FieldName = 'Line_Amount'
      DisplayFormat = '0.00'
    end
  end
  object DataSource2: TDataSource
    DataSet = ADOTable2
    Left = 168
    Top = 40
  end
end
