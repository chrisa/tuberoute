CREATE OR REPLACE PACKAGE BODY dijkstra AS

PROCEDURE nodeset_sssp (
          p_START_NODS_ID IN  NUMBER
        , p_END_NODS_ID   IN  NUMBER
        , p_PATH          OUT GenericCurTyp ) AS
        v_START_NODE_ID NUMBER;
        v_END_NODE_ID   NUMBER;
        v_SP_ELEM       SHORTEST_PATH_ELEMENT;
        v_SP            SHORTEST_PATH;
BEGIN
        -- look up possible nodes for each nodeset
        BEGIN
        SELECT node_id 
          INTO v_START_NODE_ID 
          FROM nodes
         WHERE node_nods_id = p_START_NODS_ID
           AND ROWNUM = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        BEGIN
        SELECT node_id 
          INTO v_END_NODE_ID 
          FROM nodes
         WHERE node_nods_id = p_END_NODS_ID
           AND ROWNUM = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        -- if we got a node for each end, run the sssp routine.
        IF (v_START_NODE_ID IS NOT NULL AND v_END_NODE_ID IS NOT NULL) 
        THEN
          node_sssp(v_START_NODE_ID, v_END_NODE_ID, v_SP);
          
          -- we picked an arbitrary node from the nodeset the caller
          -- specified, so we need to allow for that. 

          -- if the first two nodes are the same nodeset, prune the first. 
          IF (v_SP(1).nods_id = v_SP(2).nods_id) 
          THEN 
            v_SP(2).edge_id := NULL;
            v_SP.DELETE(1);
          END IF;
                    
          -- if the last two nodes are the same nodeset, prune the last.                    
          IF (v_SP(v_SP.LAST).nods_id = v_SP(v_SP.LAST - 1).nods_id)
            THEN v_SP.TRIM;
          END IF;

          -- return a cursor opened on our table. 
          OPEN p_PATH
           FOR SELECT *
          FROM TABLE ( CAST ( v_SP AS SHORTEST_PATH ) );

        END IF;
END;

PROCEDURE node_sssp ( 
	  p_START_NODE_ID IN  NUMBER
	, p_END_NODE_ID   IN  NUMBER
	, p_PATH	  OUT SHORTEST_PATH ) AS
	v_NODE_COUNT NUMBER;
	v_I NUMBER;
	v_CUR_NODE NUMBER;
	v_CUR_NODE_COST NUMBER;
BEGIN
	DELETE FROM prio_queue;

	-- suck nodes into temp table, set all costs to 0, all done_yn to 'N'. 
	INSERT INTO prio_queue (prio_node_id, prio_node_cost, prio_done_yn)
        	SELECT node_id, 
                       DECODE(node_id, p_START_NODE_ID, 0, 9999), 
                       'N'
                  FROM nodes WHERE node_ntyp_id = 1;

	v_NODE_COUNT := SQL%ROWCOUNT;

	-- iterate over nodes
	<<node_loop>>
	FOR v_I IN 1 .. (v_NODE_COUNT - 1) LOOP

	    -- get current lowest cost node
	    SELECT prio_node_id, prio_node_cost
              INTO v_CUR_NODE, v_CUR_NODE_COST
              FROM (SELECT prio_node_id, 
	                   prio_node_cost
                      FROM prio_queue
		     WHERE prio_done_yn = 'N'
                     ORDER BY prio_node_cost ASC)
             WHERE ROWNUM = 1;

	    -- update its neighbors
		UPDATE prio_queue
		   SET prio_node_cost = ( v_CUR_NODE_COST + c_weight (prio_pred_edge)),
		       prio_node_pred = v_CUR_NODE,
		       prio_pred_edge = (SELECT edge_id
					   FROM edges
					  WHERE edge_node_a_id = v_CUR_NODE
					    AND edge_node_b_id = prio_node_id) 
		 WHERE prio_node_id IN (SELECT node_id FROM (SELECT edge_node_b_id AS node_id,
								    prio_node_cost
							       FROM edges E,
								    prio_queue PQ
							      WHERE E.edge_node_a_id = v_CUR_NODE
								AND E.edge_node_b_id = PQ.prio_node_id
								AND (v_CUR_NODE_COST + c_weight(E.edge_id)) < PQ.prio_node_cost));
						 
		    -- set this node done
	    UPDATE prio_queue SET prio_done_yn = 'Y' WHERE prio_node_id = v_CUR_NODE;

	END LOOP;

       SELECT SHORTEST_PATH_ELEMENT(node_id, 
              nods_id, 
              name, 
              line_name,
	      edge_id,
	      direction,
	      node_osx,
	      node_osy)
         BULK COLLECT INTO p_PATH
         FROM (
 	 SELECT prio_node_id AS node_id,
                NVL(node_name,nods_name) AS name,
		nods_id,
		dire_name AS direction,
		line_name, 
		prio_pred_edge AS edge_id,
		node_osx,
		node_osy,
		ROWNUM
           FROM prio_queue
           JOIN nodes
             ON node_id = prio_node_id
           JOIN nodesets
             ON node_nods_id = nods_id
	   JOIN node_lines
             ON nodl_node_id = node_id
           JOIN lines
             ON nodl_line_id = line_id
	   JOIN directions
             ON node_dire_id = dire_id
     START WITH prio_node_id = p_END_NODE_ID
     CONNECT BY prio_node_id = PRIOR prio_node_pred
              ) ORDER BY ROWNUM DESC;

END;-- of proc

PROCEDURE node_sssp2 ( 
	  p_START_NODE_ID IN  NUMBER
	, p_END_NODE_ID   IN  NUMBER
	, p_PATH	  OUT GenericCurTyp ) AS
	v_NODE_COUNT_S NUMBER;
	v_NODE_COUNT_E NUMBER;
	v_CUR_NODE NUMBER;
	v_CUR_NODE_COST NUMBER;
	v_MEET_ID NUMBER;
BEGIN
	DELETE FROM prio_queue_s;
	DELETE FROM prio_queue_e;

	-- suck nodes into temp tables, set all costs to 0, all done_yn to 'N'
	-- except that in queue_s START_NODE has cost 9999
	-- and in queue_e END_NODE has cost 9999
	INSERT INTO prio_queue_s (prio_node_id, prio_node_cost, prio_done_yn)
        	SELECT node_id, 
                       DECODE(node_id, p_START_NODE_ID, 0, 9999), 
                       'N'
                  FROM nodes WHERE node_ntyp_id = 1;
	v_NODE_COUNT_S := SQL%ROWCOUNT;

	INSERT INTO prio_queue_e (prio_node_id, prio_node_cost, prio_done_yn)
        	SELECT node_id, 
                       DECODE(node_id, p_END_NODE_ID, 0, 9999), 
                       'N'
                  FROM nodes WHERE node_ntyp_id = 1;
	v_NODE_COUNT_E := SQL%ROWCOUNT;

	-- iterate over nodes
	<<node_loop>>
	FOR v_I IN 1 .. (v_NODE_COUNT_S - 1) LOOP

	    -- do queue_s:

	    -- get current lowest cost node for queue_s
	    SELECT prio_node_id, prio_node_cost
              INTO v_CUR_NODE, v_CUR_NODE_COST
              FROM (SELECT prio_node_id, 
	                   prio_node_cost
                      FROM prio_queue_s
		     WHERE prio_done_yn = 'N'
                     ORDER BY prio_node_cost ASC)
             WHERE ROWNUM = 1;

	    -- update its neighbors
		UPDATE prio_queue_s
		   SET prio_node_cost = ( v_CUR_NODE_COST + c_weight (prio_pred_edge)),
		       prio_node_pred = v_CUR_NODE,
		       prio_pred_edge = (SELECT edge_id
					   FROM edges
					  WHERE edge_node_a_id = v_CUR_NODE
					    AND edge_node_b_id = prio_node_id) 
		 WHERE prio_node_id IN (SELECT node_id FROM (SELECT edge_node_b_id AS node_id,
								    prio_node_cost
							       FROM edges E,
								    prio_queue_s PQ
							      WHERE E.edge_node_a_id = v_CUR_NODE
								AND E.edge_node_b_id = PQ.prio_node_id
								AND (v_CUR_NODE_COST + c_weight(E.edge_id)) < PQ.prio_node_cost));
						 
	    -- set this node done
	    UPDATE prio_queue_s SET prio_done_yn = 'Y' WHERE prio_node_id = v_CUR_NODE;


            -- and queue_e:

	    -- get current lowest cost node for queue_e
	    SELECT prio_node_id, prio_node_cost
              INTO v_CUR_NODE, v_CUR_NODE_COST
              FROM (SELECT prio_node_id,
	                   prio_node_cost
                      FROM prio_queue_e
		     WHERE prio_done_yn = 'N'
                     ORDER BY prio_node_cost ASC)
             WHERE ROWNUM = 1;

	    -- update its neighbors
                UPDATE prio_queue_e
		   SET prio_node_cost = ( v_CUR_NODE_COST + c_weight (prio_pred_edge)),
		       prio_node_pred = v_CUR_NODE,
		       prio_pred_edge = (SELECT edge_id
					   FROM edges
					  WHERE edge_node_a_id = v_CUR_NODE
					    AND edge_node_b_id = prio_node_id) 
		 WHERE prio_node_id IN (SELECT node_id FROM (SELECT edge_node_b_id AS node_id,
								    prio_node_cost
							       FROM edges E,
								    prio_queue_e PQ
							      WHERE E.edge_node_a_id = v_CUR_NODE
								AND E.edge_node_b_id = PQ.prio_node_id
								AND (v_CUR_NODE_COST + c_weight(E.edge_id)) < PQ.prio_node_cost));
	     -- set this node done
	     UPDATE prio_queue_e SET prio_done_yn = 'Y' WHERE prio_node_id = v_CUR_NODE;

	     -- see if the paths have met in the middle:

           BEGIN	     
	     SELECT s.prio_node_id
               INTO v_MEET_ID
               FROM prio_queue_s s,
	            prio_queue_e e
	      WHERE s.prio_node_id = e.prio_node_id
                AND s.prio_done_yn = 'Y'
                AND e.prio_done_yn = 'Y';

	    EXCEPTION 
                 WHEN NO_DATA_FOUND 
                 THEN NULL;

	     END;

	     IF (v_MEET_ID IS NOT NULL) THEN

	     DBMS_OUTPUT.PUT_LINE('meet id: '||v_MEET_ID);

	 OPEN p_PATH FOR

	 SELECT * FROM (

       SELECT node_id, 
              nods_id, 
              name, 
              line_name,
	      edge_id,
	      direction,
	      node_osx,
	      node_osy
         FROM (
 	 SELECT prio_node_id AS node_id,
                NVL(node_name,nods_name) AS name,
		nods_id,
		dire_name AS direction,
		line_name, 
		prio_pred_edge AS edge_id,
		node_osx,
		node_osy,
		ROWNUM
           FROM prio_queue_s
           JOIN nodes
             ON node_id = prio_node_id
           JOIN nodesets
             ON node_nods_id = nods_id
	   JOIN node_lines
             ON nodl_node_id = node_id
           JOIN lines
             ON nodl_line_id = line_id
	   JOIN directions
             ON node_dire_id = dire_id
     START WITH prio_node_id = v_MEET_ID
     CONNECT BY prio_node_id = PRIOR prio_node_pred
              ) ORDER BY ROWNUM DESC )

	      UNION ALL
	      
	      SELECT * FROM (

       SELECT node_id, 
              nods_id, 
              name, 
              line_name,
	      edge_id,
	      direction,
	      node_osx,
	      node_osy
         FROM (
 	 SELECT prio_node_id AS node_id,
                NVL(node_name,nods_name) AS name,
		nods_id,
		dire_name AS direction,
		line_name, 
		prio_pred_edge AS edge_id,
		node_osx,
		node_osy,
		ROWNUM
           FROM prio_queue_e
           JOIN nodes
             ON node_id = prio_node_id
           JOIN nodesets
             ON node_nods_id = nods_id
	   JOIN node_lines
             ON nodl_node_id = node_id
           JOIN lines
             ON nodl_line_id = line_id
	   JOIN directions
             ON node_dire_id = dire_id
     START WITH prio_node_id = v_MEET_ID
     CONNECT BY prio_node_id = PRIOR prio_node_pred
              ) ORDER BY ROWNUM ASC );

	      EXIT;	      

             END IF;
	     	     	     
	     
	END LOOP;

	IF (v_MEET_ID IS NULL) THEN
	
	 OPEN p_PATH FOR
       SELECT node_id, 
              nods_id, 
              name, 
              line_name,
	      edge_id,
	      direction,
	      node_osx,
	      node_osy
         FROM (
 	 SELECT prio_node_id AS node_id,
                NVL(node_name,nods_name) AS name,
		nods_id,
		dire_name AS direction,
		line_name, 
		prio_pred_edge AS edge_id,
		node_osx,
		node_osy,
		ROWNUM
           FROM prio_queue_e
           JOIN nodes
             ON node_id = prio_node_id
           JOIN nodesets
             ON node_nods_id = nods_id
	   JOIN node_lines
             ON nodl_node_id = node_id
           JOIN lines
             ON nodl_line_id = line_id
	   JOIN directions
             ON node_dire_id = dire_id
     START WITH prio_node_id = p_END_NODE_ID
     CONNECT BY prio_node_id = PRIOR prio_node_pred
              ) ORDER BY ROWNUM DESC;

	END IF;

END;-- of proc

END;-- of package


/

SHOW ERRORS
