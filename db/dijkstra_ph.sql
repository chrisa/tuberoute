CREATE OR REPLACE PACKAGE dijkstra AS

TYPE GenericCurTyp IS REF CURSOR;

PROCEDURE nodeset_sssp (
	  p_START_NODS_ID    IN  NUMBER
	, p_END_NODS_ID      IN  NUMBER
	, p_PATH	     OUT GenericCurTyp
);

PROCEDURE node_sssp (
	  p_START_NODE_ID    IN  NUMBER
	, p_END_NODE_ID      IN  NUMBER
	, p_PATH	     OUT SHORTEST_PATH
);

PROCEDURE node_sssp2 (
	  p_START_NODE_ID    IN  NUMBER
	, p_END_NODE_ID      IN  NUMBER
	, p_PATH	     OUT GenericCurTyp
);

END;
/
