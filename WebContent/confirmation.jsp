<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%

String name = null;
String role = null;
int cart_id = 75;
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
try {
  System.out.println(session.getAttribute("cart_id"));
  if(session.getAttribute("cart_id")!=null) {
    cart_id = (int)session.getAttribute("cart_id");
    System.out.println("a");
  }
  else{
    cart_id=-1;
  }
}catch(Exception e){
  cart_id=23;
}
%>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Confirmation Page</title>
</head>
<body>
<div class="header">
      <h1>Confirmation Page</h1>
      <%
      if(name!=null){
          out.println("<h4>Hello, "+name+"!</h4>");
        }
      else{
        //response.sendRedirect("/CSE135/redirectlogin");
      }
      %>
</div>
<div class="contents">
  <h3>You just bought:</h3>
  <table>
      <tr>
        <td>
          <%-- Import the java.sql package --%>
          <%@ page import="java.sql.*"%>
          <%-- -------- Open Connection Code -------- --%>
          <%
          System.out.println(cart_id+"b");
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
              "user=postgres&password=postgres");
            
            conn.setAutoCommit(false);
            stmt2 = conn.createStatement();
            //System.out.println(cart_id);
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
        </td>
      </tr>
    </table>
    <%
    out.println("<h3>For $"+session.getAttribute("total")+"</h3>");
    session.removeAttribute("cart_id");
    session.removeAttribute("total");
    %>
</div>
<br>
<a href="/CSE135/browsing">Back to Product Browsing</a>
</body>
</html>