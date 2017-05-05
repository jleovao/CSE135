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
        <h1>Products Page</h1>
        <%
        String errorValue = null;
        String category = request.getParameter("category");
        String searchFilter = request.getParameter("searchValue");
        errorValue = request.getParameter("error");
        if(name!=null){
          out.println("<h4>Hello, "+name+"!</h4>");
          out.println("<p>Category filter: "+category+"</p>");
          out.println("<p>Search filter: "+searchFilter+"</p>");
          if(errorValue != null && errorValue.equals("insert")) {
        	  out.println("Failure to insert new product!");
          }
          else if(errorValue != null && errorValue.equals("update")) {
        	  out.println("Failure to update product!");
          }
        }
        else{
          response.sendRedirect("/CSE135/redirectlogin");
        }
        %>
        <%-- Import the java.sql package --%>
        <%@ page import="java.sql.*"%>
        <%@ page import="java.math.BigDecimal"%>
        <%@ page import="java.util.*"%>
        <%-- -------- Open Connection Code -------- --%>
        <%
            
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ResultSet rs_category = null;
        ResultSet rs_product = null;
        ResultSet rs_menu = null;
        String action = null;
            
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
        //try {
        action = request.getParameter("action");
        // Check if an insertion is requested
        if (action != null && action.equals("insert")) {
          // Begin transaction
          conn.setAutoCommit(false);
          // Create the prepared statement and use it to
          // INSERT product values INTO the product table.
          pstmt = conn
          .prepareStatement("INSERT INTO PRODUCT(product_name,sku,category_name,price) values(?, ?, ?, ?)");
          pstmt.setString(1, request.getParameter("name"));
          pstmt.setString(2, request.getParameter("sku"));
          pstmt.setString(3, request.getParameter("category"));
          pstmt.setBigDecimal(4, new BigDecimal(request.getParameter("price")));
          
          int rowCount = pstmt.executeUpdate();

          // Commit transaction
          conn.commit();
          conn.setAutoCommit(true);
          out.println("Product added successfully!");
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
          .prepareStatement("UPDATE product SET product_name = ?, sku = ?, "
                          + "category_name = ?, price = ? WHERE product_id = ?");

        pstmt.setString(1, request.getParameter("product_name"));
        pstmt.setString(2, request.getParameter("sku"));
        pstmt.setString(3, request.getParameter("category_name"));
        pstmt.setBigDecimal(4, new BigDecimal(request.getParameter("price")));
        pstmt.setInt(5, Integer.parseInt(request.getParameter("id")));
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
          .prepareStatement("DELETE FROM product WHERE sku = ?");

        pstmt.setString(1, request.getParameter("sku"));
        int rowCount = pstmt.executeUpdate();

        // Commit transaction
        conn.commit();
        conn.setAutoCommit(true);
        }
        %>
        
      </div>
      <div class="searchBar">
      	<form action="./products.jsp?category=<%=request.getParameter("category")%>&error=none" method="POST">
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
          Statement menu_stmnt = conn.createStatement();
          // Get the list of categories for the dropdown menus
          rs_menu = menu_stmnt.executeQuery("SELECT category_name FROM categories");
          // Arraylist to hold a list of categories for dropdown menu
          List<String> menu = new ArrayList<String>();
          while(rs_menu.next()) {
        	  menu.add(rs_menu.getString("category_name"));
          }
          %>   
          
          <%
          while(rs.next()) {
          %>
            <li>
              <%-- Pass category name and search value as parameter in URL --%>
              <a href="./products.jsp?category=<%=rs.getString("category_name")%>&searchValue=<%=request.getParameter("searchValue")%>&error=none">
                <%=rs.getString("category_name")%>
              </a>
            </li>
          <%
          } // End While
          %>
          <li><a href="./products.jsp?category=AllProducts&searchValue=<%=request.getParameter("searchValue")%>&error=none">All Products</a></li>
          </ul>
            <h2>Home</h2>
          <ul>  	
          	 <li><a href="./categories.jsp">Categories</a></li>
          	 <li><a href="./products.jsp">Products</a></li>
          	 <li><a href="./browsing.jsp">Product Browsing</a></li>
          	 <li><a href="./order.jsp">Product Order</a></li>
          	 <li><a href="./cart.jsp">Shopping Cart</a></li>
          </ul>
      </div>
      <div class = "DisplayTable">
	    <table border ="1">
	      <tr>
	        <th>Product Name</th>
	        <th>SKU</th>
	        <th>Category</th>
	        <th>Price</th>
	      </tr>
	      <tr>
            <form action="./products.jsp?category=<%=category%>&searchValue=<%=searchFilter%>&error=none" method="POST">
              <input type="hidden" name="action" value="insert"/>
              <th><input value="" name="name"/></th>
              <th><input value="" name="sku"/></th>
              <th>
                <select name="category">
                <%
                Statement category_stmnt = conn.createStatement();
                // Use the created statement to SELECT
                // the distinct category names from the category table
                rs_category = category_stmnt.executeQuery("SELECT category_name FROM categories ORDER BY category_name ASC");
                while(rs_category.next()) {
                %>	  
                  <option value="<%= rs_category.getString("category_name")%>"><%= rs_category.getString("category_name")%></option>
                <%
                } // End while
                %>
            	</select>
              </th>
              <th><input value="" name="price" size="15"/></th>
              <th><input type="submit" value="Insert"/></th>
           	</form>
          </tr>
          
          <%
          Statement product_stmnt = conn.createStatement();
          // 1-No category chosen, no search filter
          String product_query = null;
          if(category == null && searchFilter == null) {
        	//out.println("Everything is null!");
            product_query="SELECT product_id,product_name,sku,category_name,price FROM product";
          }
          // 2-No category chosen, search filter applied
          else if((category == null || category.equals("null")) && (searchFilter != null || !searchFilter.equals("null"))) {
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
          else if((category != null || !category.equals("null")) && !category.equals("AllProducts") && (searchFilter == null || searchFilter.equals("null"))) {
            //out.println("category chosen, no search filter...");
            product_query="SELECT product_id,product_name,sku,category_name,price FROM product WHERE category_name = '"+category+"'";
          }
          // 5-User wants to display all products, search filter applied
          else if(category.equals("AllProducts") && (searchFilter != null || !searchFilter.equals("null"))) {
            //out.println("All products, search filter applied...");
            product_query="SELECT product_id,product_name,sku,category_name,price FROM product " 
                                                  + "WHERE product_name LIKE '%" + searchFilter + "%'";
          }
          // 6-User chose a category, search filter applied
          else if(((category != null || !category.equals("null")) && category != "AllProducts") && searchFilter != null) {
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
            <form action="./products.jsp?category=<%=rs_product.getString("category_name")%>&searchValue=<%=searchFilter%>&error=none" method="POST">
            <input type="hidden" name="action" value="update"/>
            <input type="hidden" name="id" value="<%=rs_product.getInt("product_id")%>"/>
            
            <%-- Get the product_name --%>
            <td>
            <input value="<%=rs_product.getString("product_name")%>" name="product_name"/>
            </td>
            <%-- Get the SKU --%>
            <td>
            <input value="<%=rs_product.getString("sku")%>" name="sku"/>
            </td>
            <%-- Get the category_name --%>
            <td>
              <select name="category_name">  
                <option value="<%=rs_product.getString("category_name")%>"><%=rs_product.getString("category_name")%></option>
                
                <%
                for(String elem: menu) {
                  if(!elem.equals(rs_product.getString("category_name"))) {
                %>
                    <option value="<%=elem%>"><%=elem%></option> 
                <%	
                  } // End if
                %>
                <%    
                  } // End for
                %>
                
              </select>
            </td>
            <%-- Get the price --%>
            <td>
            <input value="<%=rs_product.getBigDecimal("price")%>" name="price"/>
            </td>
            <%-- Button --%>
            <td><input type="submit" value="Update"></td>
            </form>
            <form action="./products.jsp?category=<%=category%>&searchValue=<%=searchFilter%>&error=none" method="POST">
              <input type="hidden" name="action" value="delete"/>
              <input type="hidden" value="<%=rs_product.getString("sku")%>" name="sku"/>
              <%-- Button --%>
              <td><input type="submit" value="Delete"/></td>
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
        rs_category.close();
        rs_product.close();

        // Close the Connection
        conn.close();
            		
        } catch (SQLException e) {
          // Wrap the SQL exception in a runtime exception to propagate
          // it upwards
          if(action.equals("insert")) { %>
		    <p>Error inserting product!</p>
            <%response.sendRedirect("./products.jsp?category=" + category + "&searchValue=" + searchFilter + "&error=insert");  
          }
          else if(action.equals("update")) { %>
        	  <p>Error updating product!</p>
        	<%response.sendRedirect("/CSE135/products.jsp?category=" + category + "&searchValue=" + searchFilter + "&error=update");
          }
          else {
            throw new RuntimeException(e);
          }
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
          if (rs_category != null) {
              try {
                rs_category.close();
              } catch (SQLException e) { } // Ignore
              rs_category = null;
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