CREATE OR REPLACE TYPE shortest_path_element AS OBJECT (
     node_id    NUMBER(4),
     nods_id    NUMBER(4),
     name       VARCHAR2(256),
     line_name  VARCHAR2(100),
     edge_id    NUMBER(4),
     direction  VARCHAR2(100),
     node_osx   NUMBER(6),
     node_osy   NUMBER(6)
);
/

CREATE OR REPLACE TYPE shortest_path AS TABLE OF shortest_path_element;
/
