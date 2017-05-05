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
  if(role.equals("customer")) {
    response.sendRedirect("/CSE135/redirectaccess");
  }
  %>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Categories Page</title>
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
        <h1>Categories Page</h1>
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
          <li><a href="./categories.jsp">Categories</a></li>
          <li><a href="./products.jsp">Products</a></li>
          <li><a href="./browsing.jsp">Product Browsing</a></li>
          <li><a href="./order.jsp">Product Order</a></li>
          <li><a href="./cart.jsp">Shopping Cart</a></li>
        </ul>
      </div>

      <table>
		<tr>
            <td>
            	<%-- Import the java.sql package --%>
            	<%@ page import="java.sql.*"%>
            	<%-- -------- Open Connection Code -------- --%>
            	<%
            
            	Connection conn = null;
            	PreparedStatement pstmt = null;
            	ResultSet rs = null;
            	ResultSet rs2 = null;
            
            	try {
                	// Registering Postgresql JDBC driver with the DriverManager
                	Class.forName("org.postgresql.Driver");

                	// Open a connection to the database using DriverManager
                	conn = DriverManager.getConnection(
                    	"jdbc:postgresql://localhost/Shopping_Application?" +
                    	"user=postgres&password=7124804");
            	%>
            	<%-- -------- INSERT Code -------- --%>
            	<%
                	String action = request.getParameter("action");
                	// Check if an insertion is requested
                	if (action != null && action.equals("insert")) {

                    	// Begin transaction
                    	conn.setAutoCommit(false);

                    	// Create the prepared statement and use it to
                    	// INSERT student values INTO the categories table.
                    	pstmt = conn
                    	.prepareStatement("INSERT INTO categories (category_name, description) VALUES (?, ?)");
                    	pstmt.setString(1, request.getParameter("category_name"));
                    	pstmt.setString(2, request.getParameter("description"));
                    	int rowCount = pstmt.executeUpdate();

                    	// Commit transaction
                    	conn.commit();
                    	conn.setAutoCommit(true);
                	}
            	%>
            	<%-- -------- UPDATE Code -------- --%>
            	<%
                	// Check if an update is requested
                	if (action != null && action.equals("update")) {

                	    // Begin transaction
                    	conn.setAutoCommit(false);

                    	// Create the prepared statement and use it to
                    	// UPDATE student values in the Students table.
                    	pstmt = conn
                    	    .prepareStatement("UPDATE categories SET category_name = ?, description = ?"
                    	        + " WHERE category_id = ?");
                    	pstmt.setString(1, request.getParameter("category_name"));
                    	pstmt.setString(2, request.getParameter("description"));
                    	pstmt.setInt(3, Integer.parseInt(request.getParameter("category_id")));

                    	int rowCount = pstmt.executeUpdate();
	
    	                // Commit transaction
        	            conn.commit();
            	        conn.setAutoCommit(true);
                	}
            	%>
            	<%-- -------- DELETE Code -------- --%>
            	<%
                	// Check if a delete is requested
                	if (action != null && action.equals("delete")) {

                    	// Begin transaction
                    	conn.setAutoCommit(false);

                    	// Create the prepared statement and use it to
                    	// DELETE students FROM the Students table.
                    	pstmt = conn
                    	    .prepareStatement("DELETE FROM categories WHERE category_id = ?");

                    	pstmt.setInt(1, Integer.parseInt(request.getParameter("category_id")));
                    	int rowCount = pstmt.executeUpdate();

                    	// Commit transaction
                    	conn.commit();
                    	conn.setAutoCommit(true);
                	}
            	%>
            	<%-- -------- SELECT Statement Code -------- --%>
            	<%
                	// Create the statement
                	Statement statement = conn.createStatement();
            	    Statement statement2 = conn.createStatement();

                	// Use the created statement to SELECT
                	// the student attributes FROM the Student table.
                	rs = statement.executeQuery("SELECT * FROM categories");
            	%>
            	<table border ="1">
            		<tr>
            			<th>Category ID</th>
            			<th>Category Name</th>
                		<th>Description</th>
            		</tr>
            		<tr>
        				<form action="./categories.jsp" method="POST">
        					 <th>&nbsp;</th>
            				<input type="hidden" name="action" value="insert"/>
            				<th><input value="" name="category_name" size="20"/></th>
            				<th><input value="" name="description" size="30"/></th>
            				<th><input type="submit" value="Insert"/></th>
           				</form>
            		</tr>
            		<%-- -------- Iteration Code -------- --%>
            		<%
                	// Iterate over the ResultSet
                	while (rs.next()) {
            		%>
            			<tr>
            				<form action="./categories.jsp" method="POST">
                    		<input type="hidden" name="action" value="update"/>
                    		<input type="hidden" name="category_id" value="<%=rs.getString("category_id")%>"/>	
                    		
                    		<%-- Get the category_id --%>
                			<td>
                    			<%=rs.getInt("category_id")%>
                			</td>
                			
                    		<%-- Get the category name --%>
                			<td>
                    			<input value="<%=rs.getString("category_name")%>" name="category_name" size="20"/>
                			</td>
                			
                			<%-- Get the category description --%>
                			<td>
                    			<input value="<%=rs.getString("description")%>" name="description" size="30"/>
                			</td>
            				<%-- Button --%>
                			<td><input type="submit" value="update"></td>
                			</form>
                		    <form action="./categories.jsp" method="POST">
                    		<input type="hidden" name="action" value="delete"/>
                    		<input type="hidden" value="<%=rs.getString("category_id")%>" name="category_id"/>
                    		<%-- Button --%>
                    		<%
                    		
                    		rs2=statement2.executeQuery("select * from product where category_name='"+rs.getString("category_name")+"';");
                    		if(!rs2.next()){
                			  out.println("<td><input type=\"submit\" value=\"Delete\"/></td>");
                    		}
                    		%>
                			</form>
            			</tr>
            		<%
                	} // End While
            		%>
            		<%-- -------- Close Connection Code -------- --%>
            		<%
                		// Close the ResultSet
                		rs.close();

                		// Close the Statement
                		statement.close();

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

                		if (rs != null) {
                    		try {
                        		rs.close();
                    		} catch (SQLException e) { } // Ignore
                    			rs = null;
                		}
                		if (rs2 != null) {
                  		try {
                      		rs2.close();
                  		} catch (SQLException e) { } // Ignore
                  			rs2 = null;
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