import streamlit as st
import streamlit.components.v1 as components
import os
import pandas as pd
import numpy as np
import neo4j
from neo4j import GraphDatabase
import pyvis

class RecommendationSystem:

    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver('neo4j+s://5e7957dd.databases.neo4j.io', 
        auth=('neo4j', st.secrets["neo4j_password"]))

    def close(self):
        self.driver.close()

    def print_recommendation(self, reviewer_id):
        with self.driver.session() as session:
            recommendation = session.execute_write(self._create_and_return_recommendation, reviewer_id)
            return recommendation

    @staticmethod
    def _create_and_return_recommendation(tx, reviewer_id):
        results = tx.run("""
        CALL {
        MATCH (c:Customer {reviewer_id:$reviewer_id})-[r:REVIEWED]->(p:Product)<-[r2:REVIEWED]-(c2:Customer)-[r3:REVIEWED]->(p2:Product) 
        WHERE c<>c2 AND NOT exists((c)-[:REVIEWED]->(p2)) 
        AND r.overall >= 4
        AND r2.overall >= 4 
        AND r3.overall >= 4 
        RETURN c, p2, count(p2) AS frequency
        ORDER BY frequency DESC LIMIT 10
        } 
        RETURN p2.title, p2.second_category, p2.third_category, p2.brand
        """, reviewer_id=reviewer_id)
        records = []
        for result in results:
            records.append([result['p2.title'], result['p2.second_category'], result['p2.third_category'], result['p2.brand']])
        return records

    def graph_recommendation(self, reviewer_id):
        results = self.driver.execute_query("""
        CALL {
        MATCH (c:Customer {reviewer_id:$reviewer_id})-[r:REVIEWED]->(p:Product)<-[r2:REVIEWED]-(c2:Customer)-[r3:REVIEWED]->(p2:Product)
        WHERE c<>c2 AND NOT exists((c)-[:REVIEWED]->(p2)) 
        AND r.overall >= 4
        AND r2.overall >= 4 
        AND r3.overall >= 4 
        RETURN *, count(p2) AS frequency
        ORDER BY frequency DESC LIMIT 10
        } 
        RETURN *
        """, reviewer_id=reviewer_id, 
        result_transformer_=neo4j.Result.graph)
        return results


def visualize_result(query_graph, nodes_text_properties, reviewer_id):
    visual_graph = pyvis.network.Network()

    for node in query_graph.nodes:
        node_label = list(node.labels)[0]
        node_text = node[nodes_text_properties[node_label]]
        if node_text == reviewer_id:
            visual_graph.add_node(node.element_id, node_text, color='#e5552f')
        elif node_label == 'Product':
            visual_graph.add_node(node.element_id, node_text, color='#78c9ba')
        else:
            visual_graph.add_node(node.element_id, node_text, color='#6174ea')

    for relationship in query_graph.relationships:
        visual_graph.add_edge(
            relationship.start_node.element_id,
            relationship.end_node.element_id,
            title=relationship.type
        )
 
    return visual_graph.generate_html(name='index.html', local=True, notebook=False)

if __name__ == "__main__":
    st.set_page_config(layout="wide")
    st.title("Recommendation System")
    st.markdown("### Type a reviewer ID and get recommended products")
    st.caption('Try with A15MKE6IFGO6ZH, or with other reviewer id')
    st.text_input("Reviewer ID", key="reviewer_id")

    try:
        # Open Session
        recommender = RecommendationSystem("bolt://localhost:7687", "neo4j", "password")
        # Return Recommended Products
        records = recommender.print_recommendation(st.session_state.reviewer_id)
        # Return Graph
        graph = recommender.graph_recommendation(st.session_state.reviewer_id)
        # Close Session
        recommender.close()

        df = pd.DataFrame(np.array(records), columns=['title', 'second_category', 'third_category', 'brand'])
        df['third_category'] = df['third_category'].str.replace('amp;', '')

        st.markdown(f'#### Products recommended to :red[{st.session_state.reviewer_id}] based on customers \
        that rated more than 4 stars in same reviewed product')
        st.dataframe(df)

        # Draw graph
        nodes_text_properties = {  # what property to use as text for each node
            "Product": "title",
            "Customer": "reviewer_id",
        }
        
        components.html(visualize_result(graph, nodes_text_properties, reviewer_id=st.session_state.reviewer_id),
                        scrolling=True, 
                        height=800)
    except Exception as e:
        st.markdown("### Any recommendations found")
        st.caption(e)
    


