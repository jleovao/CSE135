<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
  <%
  String name=null;
  String role=null;
  try{
    if(session.getAttribute("name")!=null || !session.getAttribute("name").equals("")) {
      name=(String) session.getAttribute("name");
    }
    else{name=null;}
  
    if(session.getAttribute("role")!=null || !session.getAttribute("role").equals("")) {
      role=(String) session.getAttribute("role");
    }
    else{role=null;}
  }catch(Exception e){
    name=null;
    role=null;
  }
  //if(role.equals("customer")) {
  //  response.sendRedirect("/CSE135/redirectaccess");
  //}
  %>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Similar Products Page</title>
    <style>
      div.container {
        width: 100%;
      }
      div.header {
        padding: 1em;
        clear: left;
        text-align: center;
      }
      div.nav {
        float: left;
        max-width: 120px;
        margin: 0;
        padding: 1em;
      }
      div.categories {
        margin-left: 140px;
        padding: 1em;
        overflow: hidden;
      }
    </style>
  </head>
  
  <body>
    <div class = "container">
      <div class="header">
        <h1>Similar Products Page</h1>
        <%
        if(name!=null){
          out.println("<h4>Hello, "+name+"!</h4>");
        }
        else{
          response.sendRedirect("/CSE135/redirectlogin");
        }
        %>
      </div>
      <div class="nav">
        <ul>
          <%
          if(role.equals("owner")){
          %>  
              <li><a href="./categories.jsp">Categories</a></li>
              <li><a href="./products.jsp">Products</a></li>
              <li><a href="./analytics.jsp">Analytics</a></li>
          <%
          }
          %>
          <li><a href="./browsing.jsp">Product Browsing</a></li>
          <li><a href="./similar_products.jsp">Similar Products</a></li>
          <li><a href="./order.jsp">Product Order</a></li>
          <li><a href="./cart.jsp">Shopping Cart</a></li>
        </ul>
      </div>

      <table>
		<tr>
            <td>
            	<%-- Import the java.sql package --%>
            	<%@ page import="java.sql.*"%>
            	<%@ page import="java.util.*"%>
            	<%-- -------- Open Connection Code -------- --%>
            	<%
            
            	Connection conn = null;
            	PreparedStatement pstmt = null;
            	ResultSet rs_product_pairs = null;
            	ResultSet rs_all_customers = null;
            	ResultSet rs_cust_sales = null;
            	ResultSet rs_total_sales = null;
            	ResultSet rs_sorted = null;
            	ResultSet rs_customers = null;
            
            	try {
                	// Registering Postgresql JDBC driver with the DriverManager
                	Class.forName("org.postgresql.Driver");

                	// Open a connection to the database using DriverManager
                	conn = DriverManager.getConnection(
                    	"jdbc:postgresql://localhost/Shopping_Application?" +
                    	"user=postgres&password=7124804");
            	%>

            	<%-- -------- SELECT Statement Code -------- --%>
            	<%
                	// Create the statement
                	Statement statement = conn.createStatement();
            	    Statement all_cust_stmnt = conn.createStatement();
            	    Statement cust_product_sales = conn.createStatement();
            	    Statement total_stmnt = conn.createStatement();
            	    Statement create_cs_stmnt = conn.createStatement();
            	    Statement drop_cs = conn.createStatement();
            	    Statement if_drop_cs = conn.createStatement();
            	    Statement check_stmnt = conn.createStatement();
            	    Statement customer_stmnt = conn.createStatement();
            	    
            	    // cosine_similarity statements
            	    Statement insert_cs = conn.createStatement();
            	    Statement sorted_stmnt = conn.createStatement();
            	    
            	    
                	// Produce all pairs of products
                	rs_product_pairs = statement.executeQuery("SELECT p1.sku AS product_x, p2.sku AS product_y " +
                	                            "FROM product p1, product p2 " +
                	                            "WHERE p1.sku <> p2.sku AND p1.sku < p2.sku");
                	
                	// Get all customers and ids(-1 if no purhcases)
                	// Customers can have multiple ids if they have multiple transactions
                	rs_all_customers = all_cust_stmnt.executeQuery("SELECT u.name, COALESCE(c.id,-1) AS id FROM carts c " +
                	                                               "RIGHT OUTER JOIN users u ON c.name = u.name");
                	
                	// customer total sales on purchased products
                    rs_cust_sales = cust_product_sales.executeQuery("SELECT c.name, i.sku,SUM(i.price) AS total_sale " +
                                                                    "FROM items i,carts c WHERE c.id = i.id " +
                                                                    "GROUP BY c.name, i.sku " +
                                                                    "ORDER BY i.sku ASC");
                	
                	// Total sales of each product
                    rs_total_sales = total_stmnt.executeQuery("(SELECT i.sku,SUM(i.price) AS total_sale" + 
                                                              " FROM items i GROUP BY i.sku)" +
                                                              " UNION " +
                                                              " (SELECT p.sku, 0 AS total_sale " +
                                                              " FROM product p WHERE p.sku NOT IN( " +
                                                                 " SELECT x.sku FROM items x))");
					
                    rs_customers = customer_stmnt.executeQuery("SELECT name FROM users");
                	
                	// Drop cosine table if it exists
                    if_drop_cs.executeUpdate("DROP TABLE IF EXISTS cosine_similarity");
                	
                	// Table to hold normalized cosine similarity calculations
                    create_cs_stmnt.executeUpdate("CREATE TABLE cosine_similarity(" +
                    	                                        "cs_id SERIAL PRIMARY KEY," +
									                    	    "product_x TEXT NOT NULL,"+
									                    	    "product_y TEXT NOT NULL,"+
									                    	    "cs_value NUMERIC(5,3) NOT NULL)");
                	
                List<String> c_menu = new ArrayList<String>();
            	while(rs_customers.next()) {
            		c_menu.add(rs_customers.getString("name"));
            	}
            	
                /* Contains all customers and their id, which is -1 if they have not purchased */
                HashMap<String, Integer> customer_menu = new HashMap<String, Integer>(); 
                while(rs_all_customers.next()) {
                	customer_menu.put(rs_all_customers.getString("name"),rs_all_customers.getInt("id"));
                }
                
                /* Contains all customers and the total sales on items they purchased */
                List<String> c_sales_menu_id = new ArrayList<String>();
                List<String> c_sales_menu_sku = new ArrayList<String>();
                List<Double> c_sales_menu_total = new ArrayList<Double>();
                while(rs_cust_sales.next()){
                	c_sales_menu_id.add(rs_cust_sales.getString("name"));
                	c_sales_menu_sku.add(rs_cust_sales.getString("sku"));
                	c_sales_menu_total.add(rs_cust_sales.getDouble("total_sale"));
                }
                
                /* Contains the total sales of each product */
                HashMap<String, Double> total_menu = new HashMap<String, Double>(); 
                while(rs_total_sales.next()) {
                	total_menu.put(rs_total_sales.getString("sku"),rs_total_sales.getDouble("total_sale"));
                }    
                
                // -------- Iteration Code --------
        		
            	// Iterate over the ResultSet
           		while(rs_product_pairs.next()){ 
           			
        		String product_x = rs_product_pairs.getString("product_x");
        		String product_y = rs_product_pairs.getString("product_y");
        		double cosine_sim = 0;
        		double normalized_cosine_sim = 0;
        		double total_sales_product_xy = 0;
        		int cnt = 0;
        		// Iterate through all customers
        	    for(String entry : c_menu) {
        		    String customer = entry;
        		    double total_cust_sales_x = 0;
        		    double total_cust_sales_y = 0;
        		            		    
        		    // Check if customer has participated in a purchase
        		    if(customer_menu.get(customer) == -1) {
        		    	continue;
        		    }
        		    // used to keep track of index
        		    cnt = 0;
        		    // Get the product of the customer's total sale on both products
        		    for(String curr_sku : c_sales_menu_sku) {
        		    	// get total sales of product_x by customer
        		    	if(curr_sku.equals(product_x) && (c_sales_menu_id.get(cnt).equals(customer))) {
        		    		total_cust_sales_x = c_sales_menu_total.get(cnt);
        		    	}
        		    	// get total sales of product_y by customer
        		    	if(curr_sku.equals(product_y) && (c_sales_menu_id.get(cnt).equals(customer))) {
        		    		total_cust_sales_y = c_sales_menu_total.get(cnt);
        		    	}
        		    	cnt = cnt + 1;
        		    }
        		    // Cosine sim is sum of all customers product of total sales on product_x and product_y
        		    cosine_sim += total_cust_sales_x * total_cust_sales_y;
        		}
        		// calculate the product of the total sales of product_x and product_y
        		total_sales_product_xy = total_menu.get(product_x) * total_menu.get(product_y);
        		
        		// calculate normalized cosine sim
        		if(total_sales_product_xy == 0){
        			normalized_cosine_sim = 0;
        		}
        		else {
        		    normalized_cosine_sim = cosine_sim/total_sales_product_xy;
        		}
        		
        		 // Begin transaction
                conn.setAutoCommit(false);
        		// Insert into cosine_similarity table
        		pstmt = conn.prepareStatement("INSERT INTO cosine_similarity(product_x,product_y,cs_value) VALUES(?,?,?)");
                pstmt.setString(1, product_x);
                pstmt.setString(2, product_y);
                pstmt.setDouble(3, normalized_cosine_sim);
                
        		int rowCount = pstmt.executeUpdate();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
           		
           		} // End While

            	%>
            	
            	
            	<table border ="1">
            		<tr>
            			<th>Rank</th>
            			<th>Product X</th>
            			<th>Product Y</th>
            			<th>Normalized Cosine Similarity</th>
            		</tr>
            		<%
            		int rank = 1;
            		rs_sorted = sorted_stmnt.executeQuery("select product_x, product_y,cs_value from cosine_similarity " +
            				"order by cs_value desc limit 100");
            		while(rs_sorted.next()) {
            		%>
            		<tr>
            			<td><%=rank%></td>
            			<td><%=rs_sorted.getString("product_x") %></td>
            			<td><%=rs_sorted.getString("product_y") %></td>
            			<td><%=rs_sorted.getDouble("cs_value") %></td>
            		</tr>
            		<% 
            		rank++;
            		} // end while
            		%>
            	</table>

            		
            		
            		
            		<%-- -------- Close Connection Code -------- --%>
            		<%
                		// Close the ResultSet
                		rs_product_pairs.close();
            		    rs_all_customers.close();
            		    rs_cust_sales.close();
            		    rs_total_sales.close();
            		    rs_sorted.close();
            		    rs_customers.close();
            		    
            		    
                		// Close the Statement
                		statement.close();
                		all_cust_stmnt.close();
                		cust_product_sales.close();
                		total_stmnt.close();
                		create_cs_stmnt.close();
                		drop_cs.close();
                		check_stmnt.close();
                		insert_cs.close();
                	    sorted_stmnt.close();
                	    customer_stmnt.close();
                		
                		// Close the Connection
                		conn.close();
            		} catch (SQLException e) {

                		// Wrap the SQL exception in a runtime exception to propagate
                		// it upwards
                		throw new RuntimeException(e);
            		}
            		finally {
                		// Release resources in a finally block in reverse-order of
                		// their creation

                		if (rs_product_pairs != null) {
                    		try {
                    			rs_product_pairs.close();
                    		} catch (SQLException e) { } // Ignore
                    		rs_product_pairs = null;
                		}
                		if (rs_all_customers != null) {
                    		try {
                    			rs_all_customers.close();
                    		} catch (SQLException e) { } // Ignore
                    		rs_all_customers = null;
                		}
                		if (rs_cust_sales != null) {
                    		try {
                    			rs_cust_sales.close();
                    		} catch (SQLException e) { } // Ignore
                    		rs_cust_sales = null;
                		}
                		if (rs_total_sales != null) {
                    		try {
                    			rs_total_sales.close();
                    		} catch (SQLException e) { } // Ignore
                    		rs_total_sales = null;
                		}
                		if (rs_customers != null) {
                    		try {
                    			rs_customers.close();
                    		} catch (SQLException e) { } // Ignore
                    		rs_customers = null;
                		}
                		if (rs_sorted != null) {
                    		try {
                    			rs_sorted.close();
                    		} catch (SQLException e) { } // Ignore
                    		rs_sorted = null;
                		}
                		if (pstmt != null) {
                    		try {
                        		pstmt.close();
                    		} catch (SQLException e) { } // Ignore
                    			pstmt = null;
                		}
                		if (conn != null) {
                    		try {
                        		conn.close();
                    		} catch (SQLException e) { } // Ignore
                    			conn = null;
                		}
            		}
            		%>
            	</table>
            </td>
            </tr>
      </table>
      
    </div>
    
  </body>
</html>