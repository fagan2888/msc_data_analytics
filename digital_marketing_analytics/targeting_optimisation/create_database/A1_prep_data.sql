-- Add fields in ExtractSummary table for sales relating to 
-- different categories.


-- Sales from channel == Retail

-- Retail Total: 
alter table ExtractSummary add column ret_total_dollar numeric;
update ExtractSummary set ret_total_dollar = retf07dollars+rets07dollars+retf06dollars+rets06dollars+retf05dollars+rets05dollars+retf04dollars+rets04dollars+retpre04dollars+retpre04dollars;

-- Year over Year growth
-- Retail Total Dollar 2004
alter table ExtractSummary add column ret_total04 numeric;
update ExtractSummary set ret_total04 = retf04dollars+rets04dollars;

-- Retail Total 2005
alter table ExtractSummary add column ret_total05 numeric;
update ExtractSummary set ret_total05 = retf05dollars+rets05dollars;

-- Retail Total 2006
alter table ExtractSummary add column ret_total06 numeric;
update ExtractSummary set ret_total06 = retf06dollars+rets06dollars;

-- Retail Total 2007
alter table ExtractSummary add column ret_total07 numeric;
update ExtractSummary set ret_total07 = retf07dollars+rets07dollars;


-- Retail Total trips: 
alter table ExtractSummary add column ret_total_trips numeric;
update ExtractSummary set ret_total_trips = retf07trips+rets07trips+retf06trips+rets06trips+retf05trips+rets05trips+retf04trips+rets04trips+retpre04trips+retpre04trips;


-- Sales from channel == Internet

-- Int GDollar and NGDollar: 
alter table ExtractSummary add column int_total_gdollar numeric;
alter table ExtractSummary add column int_total_ngdollar numeric;
update ExtractSummary set int_total_gdollar = intf07gdollars+ints07gdollars+intf06gdollars+ints06gdollars+intf05gdollars+ints05gdollars+intf04gdollars+ints04gdollars++intpre04gdollars;
update ExtractSummary set int_total_ngdollar = intf07ngdollars+ints07ngdollars+intf06ngdollars+ints06ngdollars+intf05ngdollars+ints05ngdollars+intf04ngdollars+ints04ngdollars++intpre04ngdollars;

-- Internet Total Orders
alter table ExtractSummary add column int_total_orders numeric;
update ExtractSummary set int_total_orders = intf07orders+ints07orders+intf06orders+ints06orders+intf05orders+ints05orders+intf04orders+ints04orders+intpre04orders+intpre04orders;

-- Year over Year growth
-- Internet Total Orders 2004
alter table ExtractSummary add column int_total_orders04 numeric;
update ExtractSummary set int_total_orders04 = intf04orders+ints04orders;

-- Internet Total Orders 2005
alter table ExtractSummary add column int_total_orders05 numeric;
update ExtractSummary set int_total_orders05 = intf05orders+ints05orders;

-- Internet Total Orders 2006
alter table ExtractSummary add column int_total_orders06 numeric;
update ExtractSummary set int_total_orders06 = intf06orders+ints06orders;

-- Internet Total Orders 2007
alter table ExtractSummary add column int_total_orders07 numeric;
update ExtractSummary set int_total_orders07 = intf07orders+ints07orders;


-- Int Total lines
alter table ExtractSummary add column int_total_lines numeric;
update ExtractSummary set int_total_lines = intf07lines+ints07lines+intf06lines+ints06lines+intf05lines+ints05lines+intf04lines+ints04lines+intpre04lines+intpre04lines;


-- Sales from channel == Catalogue

-- Catalogue GDollar and NGDollar
alter table ExtractSummary add column cat_total_gdollar numeric;
alter table ExtractSummary add column cat_total_ngdollar numeric;
update ExtractSummary set cat_total_gdollar = catf07gdollars+cats07gdollars+catf06gdollars+cats06gdollars+catf05gdollars+cats05gdollars+catf04gdollars+cats04gdollars++catpre04gdollars;
update ExtractSummary set cat_total_ngdollar = catf07ngdollars+cats07ngdollars+catf06ngdollars+cats06ngdollars+catf05ngdollars+cats05ngdollars+catf04ngdollars+cats04ngdollars++catpre04ngdollars;

-- Catalogue Total Orders
alter table ExtractSummary add column cat_total_orders numeric;
update ExtractSummary set cat_total_orders = catf07orders+cats07orders+catf06orders+cats06orders+catf05orders+cats05orders+catf04orders+cats04orders+catpre04orders+catpre04orders;

-- Year over Year growth
-- Catalogue Total Orders 2004
alter table ExtractSummary add column cat_total_orders04 numeric;
update ExtractSummary set cat_total_orders04 = catf04orders+cats04orders;

-- Catalogue Total Orders 2005
alter table ExtractSummary add column cat_total_orders05 numeric;
update ExtractSummary set cat_total_orders05 = catf05orders+cats05orders;

-- Catalogue Total Orders 2006
alter table ExtractSummary add column cat_total_orders06 numeric;
update ExtractSummary set cat_total_orders06 = catf06orders+cats06orders;

-- Catalogue Total Orders 2007
alter table ExtractSummary add column cat_total_orders07 numeric;
update ExtractSummary set cat_total_orders07 = catf07orders+cats07orders;


-- Catalogue Total lines
alter table ExtractSummary add column cat_total_lines numeric;
update ExtractSummary set cat_total_lines = catf07lines+cats07lines+catf06lines+cats06lines+catf05lines+cats05lines+catf04lines+cats04lines+catpre04lines+catpre04lines;

