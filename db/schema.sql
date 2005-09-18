--CREATE TABLESPACE map DATAFILE 'map01.dbf' SIZE 32M AUTOEXTEND ON;

-- SEQUENCES

CREATE SEQUENCE map.dire_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;

CREATE SEQUENCE map.edge_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;

CREATE SEQUENCE map.edgl_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;

CREATE SEQUENCE map.edgw_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;

CREATE SEQUENCE map.line_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;

CREATE SEQUENCE map.node_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;

CREATE SEQUENCE map.nods_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;

CREATE SEQUENCE map.nodl_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;

CREATE SEQUENCE map.ntyp_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;

CREATE SEQUENCE map.weig_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;

CREATE SEQUENCE map.edgt_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;

CREATE SEQUENCE map.nstp_id_seq START WITH 1 INCREMENT BY 1
NOMINVALUE
NOMAXVALUE
NOCYCLE
NOCACHE;



-- ==============================================================


CREATE TABLE map.nodesets
(
    nods_id       NUMBER (4) NOT NULL
    nods_nstp_id  NUMBER (4)
  , nods_name     VARCHAR2 (256) 
);

CREATE UNIQUE INDEX map.pk_nods ON map.nodesets
(
    nods_id
);

ALTER TABLE map.nodesets ADD CONSTRAINT pk_nods PRIMARY KEY
(
    nods_id
);

-- ==============================================================


CREATE TABLE map.nodeset_types
(
    nstp_id            NUMBER (4) NOT NULL
  , nstp_type_name     VARCHAR2 (256) 
);

CREATE UNIQUE INDEX map.pk_nstp ON map.nodeset_types
(
    nstp_id
);

ALTER TABLE map.nodeset_types ADD CONSTRAINT pk_nstp PRIMARY KEY
(
    nstp_id
);

-- ================================================================

CREATE TABLE map.nodes
(
    node_id         NUMBER (4) NOT NULL
  , node_nods_id    NUMBER (4) NOT NULL  
  , node_ntyp_id    NUMBER (4) NOT NULL
  , node_name       VARCHAR2(100) 
  , node_dire_id    NUMBER (4) NOT NULL
  , node_osx        NUMBER (6)
  , node_osy        NUMBER (6)
  , node_deleted_yn VARCHAR2 (1) NOT NULL
);

CREATE UNIQUE INDEX map.pk_node ON map.nodes
(
    node_id
);

ALTER TABLE map.nodes ADD CONSTRAINT pk_node PRIMARY KEY
(
    node_id
);

-- ================================================================

CREATE TABLE map.edges
(
     edge_id        NUMBER (4) NOT NULL
  ,  edge_node_a_id NUMBER (4) NOT NULL
  ,  edge_node_b_id NUMBER (4) NOT NULL
  ,  edge_edgt_id   NUMBER (4) NOT NULL
);

CREATE UNIQUE INDEX map.pk_edge ON map.edges
(
    edge_id
);

CREATE UNIQUE INDEX map.edges1 ON map.edges
(
    edge_id,
    edge_node_b_id
);

ALTER TABLE map.edges ADD CONSTRAINT pk_edge PRIMARY KEY
(
    edge_id
);

ALTER TABLE map.edges ADD CONSTRAINT u_edges_1 UNIQUE
(
    edge_node_a_id,
    edge_node_b_id
);

-- ================================================================

CREATE TABLE map.node_types
(
    ntyp_id        NUMBER (4) NOT NULL
  , ntyp_type_name VARCHAR2 (100)
);

CREATE UNIQUE INDEX map.pk_ntyp ON map.node_types
(
    ntyp_id
);

ALTER TABLE map.node_types ADD CONSTRAINT pk_ntyp PRIMARY KEY
(
    ntyp_id
);

-- ================================================================

CREATE TABLE map.directions
(
    dire_id       NUMBER (4) NOT NULL
  , dire_name     VARCHAR2(100) 
);

CREATE UNIQUE INDEX map.pk_dire ON map.directions
(
    dire_id
);

ALTER TABLE map.directions ADD CONSTRAINT pk_dire PRIMARY KEY
(
    dire_id
);

-- ================================================================

CREATE TABLE map.lines
(
    line_id       NUMBER (4) NOT NULL
  , line_name     VARCHAR2(100)
  , line_colour   VARCHAR2(6)
);

CREATE UNIQUE INDEX map.pk_line ON map.lines
(
    line_id
);

ALTER TABLE map.lines ADD CONSTRAINT pk_line PRIMARY KEY
(
    line_id
);

-- ================================================================

CREATE TABLE map.edge_lines
(
    edgl_id       NUMBER (4) NOT NULL
  , edgl_edge_id  NUMBER (4) NOT NULL  
  , edgl_line_id  NUMBER (4) NOT NULL  
);

CREATE UNIQUE INDEX map.pk_edgl ON map.edge_lines
(
    edgl_id
);

ALTER TABLE map.edge_lines ADD CONSTRAINT pk_edgl PRIMARY KEY
(
    edgl_id
);

-- ================================================================

CREATE TABLE map.node_lines
(
    nodl_id       NUMBER (4) NOT NULL
  , nodl_node_id  NUMBER (4) NOT NULL  
  , nodl_line_id  NUMBER (4) NOT NULL  
);

CREATE UNIQUE INDEX map.pk_nodl ON map.node_lines
(
    nodl_id
);

ALTER TABLE map.node_lines ADD CONSTRAINT pk_nodl PRIMARY KEY
(
    nodl_id
);

-- ================================================================

CREATE TABLE map.weights
(
    weig_id         NUMBER (4) NOT NULL
  , weig_name       VARCHAR2(100) 
  , weig_multiplier NUMBER (4) NOT NULL
);

CREATE UNIQUE INDEX map.pk_weig ON map.weights
(
    weig_id
);

ALTER TABLE map.weights ADD CONSTRAINT pk_weig PRIMARY KEY
(
    weig_id
);

-- ================================================================

CREATE TABLE map.edge_weights
(
    edgw_id       NUMBER (4) NOT NULL
  , edgw_edge_id  NUMBER (4) NOT NULL  
  , edgw_weig_id  NUMBER (4) NOT NULL  
  , edgw_weight   NUMBER (4) NOT NULL
);

CREATE UNIQUE INDEX map.pk_edgw ON map.edge_weights
(
    edgw_id
);

CREATE UNIQUE INDEX map.edgw1 ON map.edge_weights
(
    edgw_id,
    edgw_edge_id
);

ALTER TABLE map.edge_weights ADD CONSTRAINT pk_edgw PRIMARY KEY
(
    edgw_id
);

-- ================================================================

CREATE TABLE map.edge_types
(
    edgt_id       NUMBER (4) NOT NULL
  , edgt_name	  VARCHAR2 (100) NOT NULL
);

CREATE UNIQUE INDEX map.pk_edgt ON map.edge_types
(
    edgt_id
);

ALTER TABLE map.edge_types ADD CONSTRAINT pk_edgt PRIMARY KEY
(
    edgt_id
);

-- ================================================================


-- FOREIGN KEY RELATIONSHIPS

ALTER TABLE map.nodes ADD  constraint fk_node_nods_id 
      FOREIGN KEY ( node_nods_id ) 
      REFERENCES map.nodesets ( nods_id );


ALTER TABLE map.nodesets ADD  constraint fk_nods_nstp_id 
      FOREIGN KEY ( nods_nstp_id ) 
      REFERENCES map.nodeset_types ( nstp_id ); 


ALTER TABLE map.nodes ADD  constraint fk_node_ntyp_id 
      FOREIGN KEY ( node_ntyp_id ) 
      REFERENCES map.node_types ( ntyp_id );
 

ALTER TABLE map.nodes ADD  constraint fk_node_dire_id 
      FOREIGN KEY ( node_dire_id ) 
      REFERENCES map.directions ( dire_id );

 
ALTER TABLE map.edges ADD  constraint fk_edge_node_a_id 
      FOREIGN KEY ( edge_node_a_id ) 
      REFERENCES map.nodes ( node_id );
 

ALTER TABLE map.edges ADD  constraint fk_edge_node_b_id 
      FOREIGN KEY ( edge_node_b_id ) 
      REFERENCES map.nodes ( node_id );


ALTER TABLE map.edges ADD  constraint fk_edge_edgt_id 
      FOREIGN KEY ( edge_edgt_id ) 
      REFERENCES map.edge_types ( edgt_id ); 


ALTER TABLE map.edge_lines ADD  constraint fk_edgl_edge_id 
      FOREIGN KEY ( edgl_edge_id ) 
      REFERENCES map.edges ( edge_id );
 

ALTER TABLE map.edge_lines ADD  constraint fk_edgl_line_id 
      FOREIGN KEY ( edgl_line_id ) 
      REFERENCES map.lines ( line_id );
 

ALTER TABLE map.node_lines ADD  constraint fk_nodl_node_id 
      FOREIGN KEY ( nodl_node_id ) 
      REFERENCES map.nodes ( node_id );
 

ALTER TABLE map.node_lines ADD  constraint fk_nodl_line_id 
      FOREIGN KEY ( nodl_line_id ) 
      REFERENCES map.lines ( line_id );
 

ALTER TABLE map.edge_weights ADD  constraint fk_edgw_edge_id 
      FOREIGN KEY ( edgw_edge_id ) 
      REFERENCES map.edges ( edge_id );
 

ALTER TABLE map.edge_weights ADD  constraint fk_edgw_weig_id 
      FOREIGN KEY ( edgw_weig_id ) 
      REFERENCES map.weights ( weig_id );
 
-- ==========================================================

-- unique constraints



-- ==========================================================

-- set-id triggers

CREATE OR REPLACE TRIGGER map.set_dire_id
BEFORE INSERT
ON map.directions
FOR EACH ROW WHEN (new.dire_id IS NULL)
BEGIN
  SELECT dire_id_seq.nextval
  INTO :new.dire_id
  FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER map.set_nstp_id
BEFORE INSERT
ON map.nodeset_types
FOR EACH ROW WHEN (new.nstp_id IS NULL)
BEGIN
  SELECT nstp_id_seq.nextval
  INTO :new.nstp_id
  FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER map.set_edge_id
BEFORE INSERT
ON map.edges
FOR EACH ROW WHEN (NEW.edge_id IS NULL)
BEGIN
  SELECT edge_id_seq.nextval
  INTO :new.edge_id
  FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER map.set_edgl_id
BEFORE INSERT
ON map.edge_lines
FOR EACH ROW WHEN (NEW.edgl_id IS NULL)
BEGIN
  SELECT edgl_id_seq.nextval
  INTO :new.edgl_id
  FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER map.set_edgw_id
BEFORE INSERT
ON map.edge_weights
FOR EACH ROW WHEN (NEW.edgw_id IS NULL)
BEGIN
  SELECT edgw_id_seq.nextval
  INTO :new.edgw_id
  FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER map.set_line_id
BEFORE INSERT
ON map.lines
FOR EACH ROW WHEN (NEW.line_id IS NULL)
BEGIN
  SELECT line_id_seq.nextval
  INTO :new.line_id
  FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER map.set_node_id
BEFORE INSERT
ON map.nodes
FOR EACH ROW WHEN (NEW.node_id IS NULL)
BEGIN
  SELECT node_id_seq.nextval
  INTO :new.node_id
  FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER map.set_nodl_id
BEFORE INSERT
ON map.node_lines
FOR EACH ROW WHEN (NEW.nodl_id IS NULL)
BEGIN
  SELECT nodl_id_seq.nextval
  INTO :new.nodl_id
  FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER map.set_nods_id
BEFORE INSERT
ON map.nodesets
FOR EACH ROW WHEN (NEW.nods_id IS NULL)
BEGIN
  SELECT nods_id_seq.nextval
  INTO :new.nods_id
  FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER map.set_ntyp_id
BEFORE INSERT
ON map.node_types
FOR EACH ROW WHEN (NEW.ntyp_id IS NULL)
BEGIN
  SELECT ntyp_id_seq.nextval
  INTO :new.ntyp_id
  FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER map.set_weig_id
BEFORE INSERT
ON map.weights
FOR EACH ROW WHEN (NEW.weig_id IS NULL)
BEGIN
  SELECT weig_id_seq.nextval
  INTO :new.weig_id
  FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER map.set_edgt_id
BEFORE INSERT
ON map.edge_types
FOR EACH ROW WHEN (NEW.edgt_id IS NULL)
BEGIN
  SELECT edgt_id_seq.nextval
  INTO :new.edgt_id
  FROM DUAL;
END;
/

-- ==========================================================

-- temporary table to support dijkstra priority queue

CREATE GLOBAL TEMPORARY TABLE prio_queue
(
	prio_node_id   NUMBER(4),
	prio_node_cost NUMBER(4),
	prio_node_pred NUMBER(4),
	prio_pred_edge NUMBER(4),
	prio_done_yn   VARCHAR2(1)
) ON COMMIT PRESERVE ROWS;

CREATE UNIQUE INDEX map.prio_queue1 ON map.prio_queue
(
    prio_node_id,
    prio_node_cost, 
    prio_done_yn
);

CREATE UNIQUE INDEX map.prio_queue2 ON map.prio_queue
(
    prio_node_id
);

-- temporary tables to support two-way dijkstra priority queues

CREATE GLOBAL TEMPORARY TABLE prio_queue_s
(
	prio_node_id   NUMBER(4),
	prio_node_cost NUMBER(4),
	prio_node_pred NUMBER(4),
	prio_pred_edge NUMBER(4),
	prio_done_yn   VARCHAR2(1)
) ON COMMIT PRESERVE ROWS;

CREATE UNIQUE INDEX map.prio_queue_s1 ON map.prio_queue_s
(
    prio_node_id,
    prio_node_cost, 
    prio_done_yn
);

CREATE UNIQUE INDEX map.prio_queue_s2 ON map.prio_queue_s
(
    prio_node_id
);

CREATE GLOBAL TEMPORARY TABLE prio_queue_e
(
	prio_node_id   NUMBER(4),
	prio_node_cost NUMBER(4),
	prio_node_pred NUMBER(4),
	prio_pred_edge NUMBER(4),
	prio_done_yn   VARCHAR2(1)
) ON COMMIT PRESERVE ROWS;

CREATE UNIQUE INDEX map.prio_queue_e1 ON map.prio_queue_e
(
    prio_node_id,
    prio_node_cost, 
    prio_done_yn
);

CREATE UNIQUE INDEX map.prio_queue_e2 ON map.prio_queue_e
(
    prio_node_id
);
