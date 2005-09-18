-- FUNCTION c_weight - takes edge_id, returns composite weight. 

CREATE OR REPLACE FUNCTION c_weight( p_EDGE_ID IN NUMBER )
RETURN NUMBER AS
 v_COMP_WEIGHT NUMBER;
BEGIN
SELECT NVL(sum ( mult * weight ), 1)
  INTO v_COMP_WEIGHT
  FROM ( SELECT edgw_weight AS weight,
		weig_multiplier AS mult
	   FROM edge_weights
	   JOIN weights
	     ON edgw_weig_id = weig_id
	  WHERE edgw_edge_id = p_EDGE_ID );
	  
RETURN v_COMP_WEIGHT;
END; -- of FUNCTION

