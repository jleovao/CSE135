<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<%
  String name=null;
  String role=null;
  String sku=null;
  double price = 0;
  double total=0;
  int cart_id = 0;
  int quant =0;
  try{
    if(session.getAttribute("name")!=null || !session.getAttribute("name").equals("")) {
      name=(String) session.getAttribute("name");
    }
  }catch(Exception e){
    name=null;
  }
  try {
    if(session.getAttribute("role")!=null || !session.getAttribute("role").equals("")) {
      role=(String) session.getAttribute("role");
    }
  }catch(Exception e){
    role=null;
  }
  try{
    if(session.getAttribute("sku")!=null || !session.getAttribute("sku").equals("")) {
      sku=(String) session.getAttribute("sku");
    }
    
  }catch(Exception e){
    sku=null;
  }
  System.out.println("SKU passed: "+sku);
  %>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Order Page</title>
    <style>
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
      div.container {
        margin-left: 140px;
        padding: 1em;
        overflow: hidden;
      }
    </style>
  </head>
  <body>
    <div class="header">
      <h1>Product Order Page</h1><%
        if(name!=null){
          out.println("<h4>Hello, "+name+"!</h4>");
        }
        else{
          response.sendRedirect("/CSE135/redirectlogin");
        }
        %>
    </div>
    
    <h3>Your Shopping Cart</h3>
    <table>
      <tr>
        <td>
          <%-- Import the java.sql package --%>
          <%@ page import="java.sql.*"%>
          <%-- -------- Open Connection Code -------- --%>
          <%
            
          Connection conn = null;
          PreparedStatement pstmt = null;
          Statement stmt = null;
          ResultSet rs = null;
          
          try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(
              "jdbc:postgresql://localhost/Shopping_Application?" +
              "user=postgres&password=7124804");
            String action = request.getParameter("action");
           //System.out.println(request.getParameter("action") );

            if(action!=null && action.equals("update")){
              quant = Integer.parseInt(request.getParameter("qty"));
              if(request.getParameter("qty").equals("0")){
                conn.setAutoCommit(false);

                pstmt = conn
                    .prepareStatement("DELETE FROM items WHERE pid = ?");

                pstmt.setInt(1, Integer.parseInt(request.getParameter("pid")));
                int rowCount = pstmt.executeUpdate();
                conn.commit();
                conn.setAutoCommit(true);
              }else{
                conn.setAutoCommit(false);
                pstmt = conn.prepareStatement("UPDATE items SET qty=?,price=? where pid=?;");
                pstmt.setInt(1,Integer.parseInt(request.getParameter("qty")));
                pstmt.setDouble(2,((Double.parseDouble(request.getParameter("each")))*quant));
                pstmt.setInt(3,Integer.parseInt(request.getParameter("pid")));
                int rowCount = pstmt.executeUpdate();
                conn.commit();
                conn.setAutoCommit(true);
              }
            }
            
            conn.setAutoCommit(false);
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM carts where purchase_date is null and name='"+name+"';");
            if(rs.next()){
              cart_id = rs.getInt("id");
            }
            else{
              pstmt = conn.prepareStatement("INSERT INTO carts(name) VALUES(?)");
              pstmt.setString(1,name);
              int rowCount = pstmt.executeUpdate();
              conn.commit();
              conn.setAutoCommit(true);
              stmt = conn.createStatement();
              rs = stmt.executeQuery("SELECT * FROM carts where purchase_date is null and name='"+name+"';");
              if(rs.next()){
                cart_id = rs.getInt("id");
              }
            }
            if(sku!=null || sku!=""){
              conn.setAutoCommit(false);
              stmt = conn.createStatement();
              rs = stmt.executeQuery("SELECT * FROM items where sku='"+sku+"' and id="+cart_id+";");
              if(rs.next()){
                quant = rs.getInt("qty")+1;
                pstmt = conn.prepareStatement("UPDATE items SET qty=?, price=? where sku=? and id=?;");
                pstmt.setInt(1,rs.getInt("qty")+1);
                pstmt.setDouble(2,((Double.parseDouble(request.getParameter("each")))*quant));
                pstmt.setString(3,sku);
                pstmt.setInt(4,cart_id);
                int rowCount = pstmt.executeUpdate();
                conn.commit();
                conn.setAutoCommit(true);
              }else {
                conn.setAutoCommit(false);
                stmt = conn.createStatement();
                rs = stmt.executeQuery("SELECT * FROM product where sku='"+sku+"';");
                if(rs.next()){
                  quant =1;
                  price = rs.getDouble("price");
                  pstmt = conn.prepareStatement("INSERT INTO items(id,sku,qty,price) VALUES(?,?,?,?)");
                  pstmt.setInt(1, cart_id);
                  pstmt.setString(2, sku);
                  pstmt.setInt(3,1);
                  pstmt.setDouble(4, (price*quant));
                  int rowCount = pstmt.executeUpdate();
                  conn.commit();
                  conn.setAutoCommit(true);
                }
              }
              session.removeAttribute("sku");
            }
            
          }catch (SQLException e){
            throw new RuntimeException(e);
          }
          %>
          
          <%
          // Create the statement
          Statement statement = conn.createStatement();
          Statement stmt2 = conn.createStatement();
          ResultSet rs2 = null;
          try{
            // Use the created statement to SELECT
            // the student attributes FROM the Student table.
            rs = statement.executeQuery("SELECT * FROM items where id="+cart_id+";");
            
          %>
          <table border="1">
            <tr>
              <th>SKU</th>
              <th>Product Name</th>
              <th>Price</th>
              <th>Quantity</th>
            </tr>
            <%
              // Iterate over the ResultSet
              while (rs.next()) {
            %>
            <tr>
              <form action="./order" method="post">
                <input type="hidden" name="action" value="update"/>
                <input type="hidden" name="pid" value="<%=rs.getInt("pid")%>"/>
                
                <td>
                  <%=rs.getString("sku")%>
                </td>
                <%
                rs2 = stmt2.executeQuery("SELECT * FROM product where sku='"+rs.getString("sku")+"';");
                if(rs2.next()){
                %>
                <td>
                  <%=rs2.getString("product_name")%>
                </td>
                <input type="hidden" name="each" value="<%=rs2.getDouble("price")%>"/>
                <td width="30%">
                  <%=rs.getDouble("price") %>
                </td>
                <td>
                  <input value=<%=rs.getInt("qty")%> name="qty"/>
                </td>
                <td><input type="submit"  value="Update"></td>
                <% 
                }//end if
                %>
              </form>
            </tr>
            <%
            } // End While
            %>
          </table>
        </td>
      </tr>
    </table>
    <%
    statement = conn.createStatement();

    // Use the created statement to SELECT
   // the student attributes FROM the Student table.
   rs = statement.executeQuery("SELECT * FROM items where id="+cart_id+";");     
   %>
   <%
   total=0;
   double each=0;
   double temp=0;
   while(rs.next()){
     each = rs.getDouble("price");
     quant = rs.getInt("qty");
     total = each + total;
   } //end while
     
   out.println("<br>Total Price: $" +total);
   }catch(SQLException e){
     throw new RuntimeException(e);
   }
          //close stuff
          finally{
            if (stmt != null) {
              try {
                stmt.close();
              } catch (SQLException e) { } // Ignore
            stmt = null;
            }
            if (stmt2 != null) {
              try {
                stmt2.close();
              } catch (SQLException e) { } // Ignore
            stmt2 = null;
            }
            if (pstmt != null) {
              try {
                pstmt.close();
              } catch (SQLException e) { } // Ignore
            pstmt = null;
            }
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
            if (conn != null) {
              try {
                conn.close();
              } catch (SQLException e) { } // Ignore
              conn = null;
            }
          }
          
   %>
   <br>
   <a href="/CSE135/buy">Buy Items</a>
   <br>
   <br>
   <%
     if(role.equals("owner")){
       out.println("<li><a href=\"/CSE135/home\">Home</a></li><br>");
     }
   %>
   <a href="/CSE135/browsing">Back to Browse</a>
  </body>

</html>