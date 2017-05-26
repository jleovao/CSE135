<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*" %>
<%@ page import="javax.servlet.*,java.text.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <%
    boolean flag = true;
    String name = null;
    String role = null;
    double price = 0;
    double total=0;
    int cart_id = 0;
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
    %>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Buy Page</title>
  </head>
  <body>
    <div class="header">
      <h1>Buy Shopping Cart Page</h1>
      <%
      if(name!=null){
          out.println("<h4>Hello, "+name+"!</h4>");
        }
      else{
        response.sendRedirect("/CSE135/redirectlogin");
      }
      %>
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
          Statement stmt = null;
          ResultSet rs = null;
          Statement stmt2 = null;
          ResultSet rs2 = null;
          
          try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(
              "jdbc:postgresql://localhost/Shopping_Application?" +
              "user=postgres&password=7124804");
            
            conn.setAutoCommit(false);
            stmt = conn.createStatement();
            stmt2 = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM carts where purchase_date is null and name='"+name+"';");
            if(rs.next()){
              cart_id = rs.getInt("id");
            }
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM items where id="+cart_id+";");
            
          %>
          <table border="1">
            <tr>
              <th>SKU</th>
              <th>Product Name</th>
              <th>Price</th>
              <th>Quantity</th>
            </tr>
            
            <%  
            //iterate for items
            while(rs.next()) {
            %>
            <tr>
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
              
              <td width="30%">
                <%=rs.getDouble("price") %>
              </td>
              <td>
                <%=rs.getInt("qty")%>
              </td>
              <% }//end if %>
            </tr>
            <%  
            }//end wihle
         %> 
        </td>
      </tr>
    </table>
    <%
      stmt = conn.createStatement();

      // Use the created statement to SELECT
      // the student attributes FROM the Student table.
      rs = stmt.executeQuery("SELECT * FROM items where id="+cart_id+";");   
      if(!rs.next()){
        flag = false;
      }
      rs = stmt.executeQuery("SELECT * FROM items where id="+cart_id+";");  
      total=0;
      double each=0;
      int quant=0;
      double temp=0;
      while(rs.next()){
        each = rs.getDouble("price");
        quant = rs.getInt("qty");
        total = each + total;
      } //end while 
      out.println("<br>Total Price: $" +total);
    
     %>
     <form>
       <input type="hidden" name="action" value="purchase"/>
       Credit Card Number:<input type="text" name="creditcard" value="" placeholder="Credit Card Number"/>
       <input type="submit" value ="Purchase"/>
     </form>
   
   <%
     String action = request.getParameter("action");
     java.util.Date dNow = new java.util.Date();
     SimpleDateFormat ft = new SimpleDateFormat("yyyy/MM/dd");
     java.sql.Date sqlStartDate = new java.sql.Date(dNow.getTime()); 
     if(action!=null && action.equals("purchase")){
       if(request.getParameter("creditcard").equals("")||request.getParameter("creditcard").equals(null)){
         out.println("<br>***Enter Credit Card Number");
       }
       if (flag == false){
         out.println("<br>***No items in cart");
       }
       else{
         
         conn.setAutoCommit(false);
         pstmt = conn.prepareStatement("UPDATE carts SET purchase_date=?,total_price=? where id=?;");
         pstmt.setDate(1,sqlStartDate);
         pstmt.setDouble(2,total);
         pstmt.setInt(3,cart_id);
         int rowCount = pstmt.executeUpdate();
         conn.commit();
         conn.setAutoCommit(true);
  
         session.setAttribute("total",total);
         session.setAttribute("cart_id", cart_id);
         response.sendRedirect("/CSE135/confirmation");
       }
     }

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
  <a href="/CSE135/home">Home</a>
  </body>
</html>