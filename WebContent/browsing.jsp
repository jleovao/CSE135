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
  %>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Products Page</title>
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
      div.products {
        margin-left: 140px;
        padding: 1em;
        overflow: hidden;
      }
      div.displayTable {
      	float: center;
      	
      }
    </style>
  </head>
  <body>
    <div class = "container">
      <div class="header">
        <h1>Products Browsing Page</h1>
        <%
        String category = request.getParameter("category");
        String searchFilter = request.getParameter("searchValue");
        if(name!=null){
          out.println("<h4>Hello, "+role + " " +name+"!</h4>");
          out.println("<p>Category filter: "+category+"</p>");
          out.println("<p>Search filter: "+searchFilter+"</p>");
        }
        else{
          response.sendRedirect("/CSE135/redirectlogin");
        }
        %>
        <%-- Import the java.sql package --%>
        <%@ page import="java.sql.*"%>
        <%@ page import="java.math.BigDecimal"%>
        <%-- -------- Open Connection Code -------- --%>
        <%
            
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ResultSet rs_product = null;
            
        try {
        	// Registering Postgresql JDBC driver with the DriverManager
            Class.forName("org.postgresql.Driver");

            // Open a connection to the database using DriverManager
            conn = DriverManager.getConnection(
                "jdbc:postgresql://localhost/Shopping_Application?" +
                "user=postgres&password=7124804");
            String action = request.getParameter("action");
            
            if(action!=null && action.equals("addcart")){
              String addsku = request.getParameter("addsku");
              System.out.println(addsku);
              session.setAttribute("sku", addsku);
              response.sendRedirect("/CSE135/order");
            }
              
            
        %>
        
      </div>
      <div class="searchBar">
      	<form action="./browsing.jsp?category=<%=category%>&error=none" method="POST">
      	  <input type="text" name="searchValue">
      	  <input type="submit" value="Search">
      	</form>
      </div>
      <div class="nav">
        <h2>Categories</h2>
        <ul>
          <%
            // Create the statement
            Statement statement = conn.createStatement();

            // Use the created statement to SELECT
            // the category_name attributes from the categories table
            rs = statement.executeQuery("SELECT category_name FROM categories ORDER BY category_name ASC");
          %>    
            
          <%
          while(rs.next()) {
          %>
            <li>
              <%-- Pass category name and search value as parameter in URL --%>
              <a href="./browsing.jsp?category=<%=rs.getString("category_name")%>&searchValue=<%=request.getParameter("searchValue")%>">
                <%=rs.getString("category_name")%>
              </a>
            </li>
          <%
          } // End While
          %>
          <li><a href="./browsing.jsp?category=AllProducts&searchValue=<%=request.getParameter("searchValue")%>">All Products</a></li>
          </ul>
            <h2>Home</h2>
          <ul>
          	<%
          	 if(role.equals("owner")) {
          	 %>
          	 <li><a href="./categories.jsp">Categories Page</a></li>
          	 <li><a href="./products.jsp">Products Page</a></li>
          	 <li><a href="./analytics.jsp">Analytics</a></li>
          	 <%
          	 }
          	 %>	
          	  <li><a href="./similar_products.jsp">Similar Products</a></li>
          	 <li><a href="./order.jsp">Product Order</a></li>
          	 <li><a href="./buy.jsp">Shopping Cart</a></li>
          </ul>
      </div>
      <div class = "DisplayTable">
	    <table border ="1">
	      <tr>
	        <th>Product Name</th>
	        <th>SKU</th>
	        <th>Category</th>
	        <th>Price</th>
	        <th>Action</th>
	      </tr>
          <%
          Statement product_stmnt = conn.createStatement();
          /*
          // 1-No category chosen, no search filter
          String product_query = null;
          if(category == null && searchFilter == null) {
            product_query="SELECT product_name,sku,category_name,price FROM product";
          }
          // 4-No category chosen, search filter applied
          else if((category == null || category.equals("null")) && (searchFilter != null || !searchFilter.equals("null"))) {
            product_query="SELECT product_name,sku,category_name,price FROM product " 
                                                  + "WHERE product_name LIKE '%" + searchFilter + "%'";           
          }
          // 2-User wants to display all products, no search filter
          else if(category.equals("AllProducts") && (searchFilter == null || searchFilter.equals("null"))) {
            product_query="SELECT product_name,sku,category_name,price FROM product";
          }
          // 3-User chose a category, no search filter
          else if((category != null || !category.equals("null")) && !category.equals("AllProducts") && (searchFilter == null || searchFilter.equals("null"))) {
            product_query="SELECT product_name,sku,category_name,price FROM product WHERE category_name = '"+category+"'";
          }
          // 5-User wants to display all products, search filter applied
          else if(category.equals("AllProducts") && (searchFilter != null || !searchFilter.equals("null"))) {
            product_query="SELECT product_name,sku,category_name,price FROM product " 
                                                  + "WHERE product_name LIKE '%" + searchFilter + "%'";
          }
          // 6-User chose a category, search filter applied
          else if(((category != null || !category.equals("null")) && category != "AllProducts") && searchFilter != null) {
            product_query="SELECT product_name,sku,category_name,price FROM product WHERE category_name = '"+category+"' AND product_name LIKE '%"+searchFilter+"%'";
          }
          // Default: Display all products
          else {
        	  product_query="SELECT product_name,sku,category_name,price from product";  
          }
          */
          
       // 1-No category chosen, no search filter
          String product_query = null;
          if(category == null && searchFilter == null) {
        	//out.println("Everything is null!");
            product_query="SELECT product_id,product_name,sku,category_name,price FROM product";
          }
          // 2-No category chosen, search filter applied
          else if((category == null || category.equals("null")) && (searchFilter != null && !searchFilter.equals("null"))) {
            //out.println("no category, searching for products containing: " + searchFilter);
            product_query="SELECT product_id,product_name,sku,category_name,price FROM product " 
                                                  + "WHERE product_name LIKE '%" + searchFilter + "%'";           
          }
          // 3-User wants to display all products, no search filter
          else if(category.equals("AllProducts") && (searchFilter == null || searchFilter.equals("null"))) {
            //out.println("AllProducts no searchFilter...");
            product_query="SELECT product_id,product_name,sku,category_name,price FROM product";
          }
          // 4-User chose a category, no search filter
          else if((category != null && !category.equals("null")) && !category.equals("AllProducts") && (searchFilter == null || searchFilter.equals("null"))) {
            //out.println("category chosen, no search filter...");
            product_query="SELECT product_id,product_name,sku,category_name,price FROM product WHERE category_name = '"+category+"'";
          }
          // 5-User wants to display all products, search filter applied
          else if(category.equals("AllProducts") && (searchFilter != null && !searchFilter.equals("null"))) {
            //out.println("All products, search filter applied...");
            product_query="SELECT product_id,product_name,sku,category_name,price FROM product " 
                                                  + "WHERE product_name LIKE '%" + searchFilter + "%'";
          }
          // 6-User chose a category, search filter applied
          else if((category != null || !category.equals("null")) && category != "AllProducts" && (searchFilter != null && !searchFilter.equals("null"))) {
            //out.println("Category chosen, search filter applied...");
            product_query="SELECT product_id,product_name,sku,category_name,price FROM product WHERE category_name = '"+category+"' AND product_name LIKE '%"+searchFilter+"%'";
          }
          // Default: Display all products
          else {
        	  //out.println("Reached default: display everything");
        	  product_query="SELECT product_id,product_name,sku,category_name,price from product";  
          }
          rs_product = product_stmnt.executeQuery(product_query);
          while(rs_product.next()) {
          %>
          
         
          <%-- A while loop to generate a row for each product based on user filtering --%>
          <tr>
           <form action="/CSE135/browsing" method="post">
           <input type="hidden" name="action" value="addcart"/>
           <input type="hidden" name="addsku" value="<%=rs_product.getString("sku")%>"/>
            <%-- Get the product_name --%>
            <td>
            <%=rs_product.getString("product_name")%>
            </td>
            <%-- Get the SKU --%>
            <td>
            <%=rs_product.getString("sku")%>
            </td>
            <%-- Get the category_name --%>
            <td>
            <%=rs_product.getString("category_name")%>
            </td>
            <%-- Get the category_name --%>
            <td>
            <%=rs_product.getBigDecimal("price")%>
            </td>
            <td><input type="submit"  value="Add to Cart"></td>
            </form>
          </tr>
          <%
          } // end while rs_product
          %>
	    </table>
      </div>
	  <%-- -------- Close Connection Code -------- --%>
      <%
        // Close the ResultSets
        rs.close();
        rs_product.close();

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
          if (rs_product != null) {
              try {
                rs_product.close();
              } catch (SQLException e) { } // Ignore
              rs_product = null;
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
    </div>
  </body>
</html>
