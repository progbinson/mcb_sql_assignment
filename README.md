# MCB SQL Assignment

This assignment was completed using Microsoft SQL Server 2022 and Microsoft SQL Server Management Studio 2022.

5 Scripts are present in the script folder:
- Creation script - this script creates all the tables and functions with necessary constraints

  
- Migration procedure - this procedure inserts data from the `XXBCM_ORDER_MGT` table to created tables


- Order summary procedure - procedure to display a summary of orders with their corresponding list of distinct invoices and their total amount

  Result:

| ORDER_NUMBER | ORDER_PERIOD | SUPPLIER_NAME          | ORDER_TOTAL_AMOUNT | ORDER_STATUS | INVOICE_REFERENCE | INVOICE_TOTAL_AMOUNT | ACTION       |
|--------------|--------------|------------------------|--------------------|--------------|-------------------|----------------------|--------------|
| 1            | JAN-2022     | Pegasus Ltd            | 10,000.00          | Closed       | INV_PO001         | 10,000.00            | OK           |
| 2            | JAN-2022     | Mottoway Corp.         | 750,000.00         | Open         | INV_PO002         | 649,000.00           | To follow up |
| 3            | JAN-2022     | Digisay Co. Ltd.       | 57,300.00          | Closed       | INV_PO003         | 57,300.00            | OK           |
| 4            | FEB-2022     | Lamboni Stat Inc.      | 6,800.00           | Closed       | INV_PO004         | 6,200.00             | OK           |
| 6            | FEB-2022     | Stuffie Stationery     | 250,000.00         | Open         | INV_PO006         | 235,000.00           | OK           |
| 5            | APR-2022     | Emtello Ltd            | 21,000.00          | Closed       | INV_PO005         | 21,000.00            | To follow up |
| 7            | JUN-2022     | Safedest Taxi Services | 26,700.00          | Closed       | INV_PO007         | 17,200.00            | OK           |
| 8            | JUN-2022     | Jinfix Computers       | 85,200.00          | Open         | INV_PO008         | 85,200.00            | OK           |
| 9            | JUN-2022     | Fireland Bros.         | 36,800.00          | Open         | INV_PO009         | 22,500.00            | OK           |
| 10           | JUL-2022     | Foxy Electronics       | 182,700.00         | Closed       | INV_PO010         | 182,700.00           | OK           |
| 11           | JUL-2022     | Lamboni Stat Inc.      | 43,200.00          | Closed       | INV_PO011         | 43,200.00            | OK           |
| 12           | AUG-2022     | Pegasus Ltd            | 265,000.00         | Open         | INV_PO012         | 241,220.00           | OK           |
| 13           | AUG-2022     | Mottoway Corp.         | 5,819,625.00       | Closed       | INV_PO013         | 5,819,625.00         | OK           |
| 14           | SEP-2022     | Digisay Co. Ltd.       | 400,120.00         | Open         | INV_PO014         | 295,520.00           | To follow up |

- Second total procedure - details for the SECOND (2nd) highest Order Total Amount from the list

Result:

| ORDER_NUMBER | ORDER_DATE | SUPPLIER_NAME | ORDER_TOTAL_AMOUNT | ORDER_STATUS | INVOICE_REFERENCES |
|---|---|---|---|---|---|
| 2 | January 10, 2022 | MOTTOWAY CORP. | 750,000.00 | Open | INV_PO002.1 \| INV_PO002.2 \| INV_PO002.3 |

- List suppliers procedure - all suppliers with their respective number of orders and total amount ordered from them between the period of 01 January 2022 and 31 August 2022

Result:
| SUPPLIER_NAME | SUPPLIER_CONTACT_NAME | SUPPLIER_CONTACT_NUMBER1 | SUPPLIER_CONTACT_NUMBER2 | TOTAL_ORDERS | ORDER_TOTAL_AMOUNT |
|---|---|---|---|---|---|
| DIGISAY CO. LTD. | Berry Parker | 5784-1266 | 602-8010 | 1 | 57300.00 |
| EMTELLO LTD | Megan Hembly | 242-0641 | 5784-1698 | 1 | 21000.00 |
| FIRELAND BROS. | Amelia Bridney | 5948-0015 | NULL | 1 | 36800.00 |
| FOXY ELECTRONICS | Reddy Floyd | 5284-5412 | NULL | 1 | 182700.00 |
| JINFIX COMPUTERS | Jordan Liu Min | 5841-2556 | 219-5412 | 1 | 85200.00 |
| LAMBONI STAT INC. | Frederic Pey | 5255-7435 | NULL | 2 | 50000.00 |
| MOTTOWAY CORP. | Stevens Seernah | 5794-2513 | NULL | 2 | 6569625.00 |
| PEGASUS LTD | Georges Neeroo | 461-5841 | 5741-2545 | 2 | 275000.00 |
| SAFEDEST TAXI SERVICES | Steeve Narsimullu | 5874-1002 | 217-4512 | 1 | 26700.00 |
| STUFFIE STATIONERY | Zenhir Belall | 654-7416 | NULL | 1 | 250000.00 |

