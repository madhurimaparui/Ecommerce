// ============================================================
// Power Query (M) — Multi-Source Data Connection
// E-Commerce Sales Intelligence Platform
// Author: Madhurima Parui
// Sources: SQL Server | Excel | SharePoint | REST API
// ============================================================


// ── SOURCE 1: SQL SERVER ───────────────────────────────────
// Query: fact_sales from EcommerceDB

let
    Source = Sql.Database("YOUR_SERVER", "EcommerceDB"),
    fact_sales = Source{[Schema="dbo", Item="fact_sales"]}[Data],
    FilterCurrentYear = Table.SelectRows(fact_sales, each [order_date_id] >= 20220101),
    AddedRevenue = Table.AddColumn(FilterCurrentYear, "Profit Margin %",
                    each if [revenue] = 0 then 0 else [profit] / [revenue] * 100,
                    type number),
    ChangedTypes = Table.TransformColumnTypes(AddedRevenue, {
        {"revenue", type number},
        {"profit", type number},
        {"discount_pct", type number}
    })
in
    ChangedTypes


// ── SOURCE 2: EXCEL FILE ───────────────────────────────────
// Query: Product master list from Excel

let
    Source = Excel.Workbook(
        File.Contents("C:\Reports\Product_Master.xlsx"),
        null, true
    ),
    ProductSheet = Source{[Item="Products", Kind="Sheet"]}[Data],
    PromotedHeaders = Table.PromoteHeaders(ProductSheet, [PromoteAllScalars=true]),
    FilterValid = Table.SelectRows(PromotedHeaders,
                    each [Product_ID] <> null and [Product_ID] <> ""),
    RenamedCols = Table.RenameColumns(FilterValid, {
        {"Product_ID",   "product_id"},
        {"Product_Name", "product_name"},
        {"Category",     "category"},
        {"Sub_Category", "sub_category"},
        {"Cost_Price",   "cost_price"},
        {"List_Price",   "list_price"}
    }),
    ChangedTypes = Table.TransformColumnTypes(RenamedCols, {
        {"product_id",  Int64.Type},
        {"cost_price",  type number},
        {"list_price",  type number}
    })
in
    ChangedTypes


// ── SOURCE 3: SHAREPOINT LIST ──────────────────────────────
// Query: Inventory data from SharePoint

let
    Source = SharePoint.Tables(
        "https://yourcompany.sharepoint.com/sites/Inventory",
        [ApiVersion = 15]
    ),
    InventoryList = Source{[Title="Inventory_Master"]}[Items],
    SelectCols = Table.SelectColumns(InventoryList, {
        "Product_ID", "Warehouse", "Stock_Qty", "Reorder_Level", "Last_Updated"
    }),
    FilterActive = Table.SelectRows(SelectCols,
                    each [Stock_Qty] <> null),
    RenamedCols = Table.RenameColumns(FilterActive, {
        {"Product_ID",    "product_id"},
        {"Warehouse",     "warehouse"},
        {"Stock_Qty",     "stock_qty"},
        {"Reorder_Level", "reorder_level"},
        {"Last_Updated",  "last_updated"}
    }),
    AddedStockStatus = Table.AddColumn(RenamedCols, "Stock_Status",
        each if [stock_qty] < [reorder_level] then "Low Stock"
             else if [stock_qty] < [reorder_level] * 2 then "Medium"
             else "Healthy",
        type text),
    ChangedTypes = Table.TransformColumnTypes(AddedStockStatus, {
        {"product_id",   Int64.Type},
        {"stock_qty",    Int64.Type},
        {"reorder_level",Int64.Type},
        {"last_updated", type datetime}
    })
in
    ChangedTypes


// ── SOURCE 4: REST API ─────────────────────────────────────
// Query: Live exchange rates from ExchangeRate API

let
    ApiUrl  = "https://api.exchangerate-api.com/v4/latest/INR",
    Source  = Web.Contents(ApiUrl),
    Parsed  = Json.Document(Source),
    Rates   = Parsed[rates],
    AsTable = Record.ToTable(Rates),
    Filtered = Table.SelectRows(AsTable, each List.Contains({"USD","EUR","GBP","AED","SGD"}, [Name])),
    RenamedCols = Table.RenameColumns(Filtered, {
        {"Name",  "currency"},
        {"Value", "rate_from_inr"}
    }),
    AddedInverse = Table.AddColumn(RenamedCols, "inr_per_unit",
                    each 1 / [rate_from_inr], type number),
    AddedDate = Table.AddColumn(AddedInverse, "rate_date",
                    each DateTime.Date(DateTime.LocalNow()), type date)
in
    AddedDate
