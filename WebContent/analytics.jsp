<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Sales Analytics</title>
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
      div.tables {
        margin-left: 140px;
        padding: 1em;
        overflow: hidden;
      }        
    </style>
  </head>

  <body> 
  <div class="container">
    <%
    String name=null;
    String role=null;
    try{
      if(session.getAttribute("name")!=null || !session.getAttribute("name").equals("")) {
        name=(String) session.getAttribute("name");
        }
      else{name="";}
  
      if(session.getAttribute("role")!=null || !session.getAttribute("role").equals("")) {
        role=(String) session.getAttribute("role");
        }
      else{role="";}
    }catch(Exception e){
      name="";
      role="";
    }
    if(name.equals("")){
      response.sendRedirect("/CSE135/redirectlogin");
      }
    else if(role.equals("customer") || role.equals("")) {
      response.sendRedirect("/CSE135/redirectaccess");
    }
    %>
  
    <%@ page import="java.sql.*"%>
    <%
    Connection conn=null;
    Statement stmt=null;
    Statement stmt2=null;
    Statement stmt3=null;
    Statement stmt4=null;
    Statement stmt5=null;
    ResultSet rs1=null;
    ResultSet rs2=null;
    ResultSet rs3=null;
    ResultSet rs4=null;
    ResultSet rs5=null;
    String[] prodarray = new String[2];
    String rows;
    String order;
    String action;
    int ind=0;
    int countrow;
    int countcol;
    boolean showcolbut = false;
    boolean showrowbut = false;
    try{
      if (session.getAttribute("countrow")!=null || !session.getAttribute("countrow").equals("")){
        countrow=(Integer)(session.getAttribute("countrow"));
      }else {
        countrow=0;
      }
    } catch (Exception e) {
      countrow=0;
    }
    try{
      if (session.getAttribute("countcol")!=null || !session.getAttribute("countcol").equals("")){
        countcol=(Integer)(session.getAttribute("countcol"));
      }else {
        countcol=0;
      }
    }catch(Exception e){
      countcol=0;
    }
    action=request.getParameter("action");
    if(action!=null && action.equals("nextrow")){
      // TODO: change back to 20
      countrow= countrow+2;
      session.setAttribute("countrow", countrow);
    }
    if(action!=null && action.equals("nextcolumn")){
      // TODO: change back to 10
      countcol=countcol+2;
      session.setAttribute("countcol", countcol);
    }
    if(action!=null && action.equals("start")){
      session.setAttribute("customerstate", request.getParameter("customerstate"));
      session.setAttribute("orderby",request.getParameter("orderby"));
      countcol =0;
      countrow=0;
      session.setAttribute("countrow", 0);
      session.setAttribute("countcol", 0);
    }
    if(action!=null && action.equals("restart")){
      session.removeAttribute("customerstate");
      session.removeAttribute("orderby");
      countcol =0;
      countrow=0;
      session.setAttribute("countrow", 0);
      session.setAttribute("countcol", 0);
    }
    try{
      if(session.getAttribute("customerstate")!=null || !session.getAttribute("customerstate").equals("")){
        rows=(String)session.getAttribute("customerstate");
      } else {
        rows="";
      }
      if(session.getAttribute("orderby")!=null || !session.getAttribute("orderby").equals("")){
        order=(String)session.getAttribute("orderby");
      } else {
        order="";
        }
    }catch(Exception e){
      rows="";
      order="";
    }
    %>
    <div class="header">
      <h1>Sales Analytics</h1>
      <%
      if(name!=null && !name.equals("")){
        out.println("<h4>Hello, "+name+"!</h4>");
      }
      %>
    </div>
    <div class="nav">
      <ul>
        <%
        if(role.equals("owner")){
          out.println("<li><a href=\"/CSE135/categories\">Categories Page(owners)</a></li>"+
                    "<li><a href=\"/CSE135/products\">Products Page(owners)</a></li>"+
                    "<li><a href=\"/CSE135/analytics\">Sales Analytics</a></li>");
        }
        %>
        <li><a href="/CSE135/browsing">Product Browsing Page</a></li>
        <li><a href="/CSE135/order">Product Order Page</a></li>
        <li><a href="/CSE135/buy">Buy Shopping Cart</a></li>
      </ul>
    </div>
    <table>
    <% 
    if ((!rows.equals("") && !order.equals(""))){ 
      try{
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost/Shopping_Application?" +
                "user=postgres&password=7124804");
      
        stmt = conn.createStatement();
        stmt2 = conn.createStatement();
        stmt3 = conn.createStatement();
        stmt4 = conn.createStatement();
        stmt5 = conn.createStatement();
        
        if(order.equals("alphabetical")){
          rs2=stmt2.executeQuery("select product_name from product order by product_name limit 2 offset "+countcol);
          %>
          <table border="1">
            <tr>
              <%if(rows.equals("customer")){ %>
              <td><b>Customer Name</b></td>
              <%}
              if(rows.equals("state")){%>
              <td><b>State</b></td>
              <%
              }
              ind=0;
              while(rs2.next()){
                prodarray[ind]=rs2.getString("product_name");
                ind++;
                %>
                <td><%=rs2.getString("product_name") %></td>
                <%
                }
              %>
            </tr>
          <%
          
          rs3=stmt3.executeQuery("select product_name from product order by product_name limit 2 offset "+(countcol+2));
          if(rs3.next()){
            showcolbut= true;
          }
          //if alphabetical customer
          if(rows.equals("customer")){
          rs1=stmt.executeQuery("select name from users order by name limit 2 offset "+countrow);
            while (rs1.next()){
              %>
              <tr>
                <%
                  String customername = rs1.getString("name");
                  %>
                  <td><%=customername %></td>
                  <%             
                  for(int i=0;i<prodarray.length;i++){
                    rs4=stmt4.executeQuery("select sum(i.qty), i.price from items i, carts c, product p where c.purchase_date is not null and i.id=c.id and c.name='"+customername+"' and p.sku=i.sku and p.product_name='"+prodarray[i]+"' group by i.price");
                    double quant = 0;
                    double price = 0;
                    double total = 0;
                    if(prodarray[i]!=null){
                      while(rs4.next()){
                        quant = (double)rs4.getInt(1);
                        price=rs4.getDouble("price");
                        total=total +(quant*price);
                      }
                      %>
                      <td><%=total %></td>
                      <%
                    }
                  }
                %>
              </tr>
              <%
            }         
            rs5=stmt5.executeQuery("select name from users order by name limit 2 offset "+(countrow+2));
            if(rs5.next()){
              showrowbut= true;
            }
          }//end if alphabet customer
          //if alphabetical state
          if(rows.equals("state")){
            rs1=stmt.executeQuery("select state from users group by state order by state limit 2 offset "+countrow);
              while (rs1.next()){
                %>
                <tr>
                  <%
                    String statename = rs1.getString("state");
                    %>
                    <td><%=statename %></td>
                    <%             
                    for(int i=0;i<prodarray.length;i++){
                      rs4=stmt4.executeQuery("select sum(i.qty), i.price from users u, items i, carts c, product p where c.purchase_date is not null and i.id=c.id and c.name=u.name and u.state='"+statename+"' and p.sku=i.sku and p.product_name='"+prodarray[i]+"' group by i.price");
                      double quant = 0;
                      double price = 0;
                      double total = 0;
                      if(prodarray[i]!=null){
                        while(rs4.next()){
                          quant = (double)rs4.getInt(1);
                          price=rs4.getDouble("price");
                          total=total +(quant*price);
                        }
                        %>
                        <td><%=total %></td>
                        <%
                      }
                    }
                  %>
                </tr>
                <%
              }         
              rs5=stmt5.executeQuery("select state from users group by state order by state limit 2 offset "+(countrow+2));
              if(rs5.next()){
                showrowbut= true;
              }
            }//end if alphabet state
          %>
          </table>
          <%         
        } //end if alphabetical
      //TODO: Figure out query statements for top-k
        if(order.equals("top-k")){
          stmt.executeQuery("select SUM(total_price),name from carts group by name order by SUM(total_price) desc limit "+countrow+",20");
        }
      }catch(Exception e){
      
      }
      %>
    
    </table>
    <%  
    } else {
    %>
    <table>
      <tr>
        <form action="/CSE135/analytics" method="post">
          <input type="hidden" name="action" value="start">
          <td>Rows Column:
            <select name="customerstate">
              <option value="customer">Customer</option>
              <option value="state">State</option>
            </select>
          </td>
          <td>Order By:
            <select name="orderby">
              <option value="alphabetical">Alphabetical</option>
              <option value="top-k">Top-K</option>
            </select>
          </td>
          <td>
            <input type="submit" value="Run Query">
          </td>
        </form>
      </tr>
    </table>
    <% } // end else %>
    <%
    if((!rows.equals("") && !order.equals(""))){
    %>
    <table>
      <tr>
      <%
      // if next 20 does not exist then do not show this button 
      if (showrowbut){
      %>
      <td>
        <form action="/CSE135/analytics" method="post">
          <input type="hidden" name="action" value="nextrow">
          <input type="submit" value="Next 20 Rows">
        </form>
      </td>
      <%
      }
      // if next 10 products does not exixt then do not show this button
      if(showcolbut){
      %>
      <td>
        <form action="/CSE135/analytics" method="post">
          <input type="hidden" name="action" value="nextcolumn">
          <input type="submit" value="Next 10 Colums">
        </form>
      </td>
      <% } %>
      </tr>
    </table>
    <%} //end if %>
    <%
    if((!rows.equals("") && !order.equals(""))){
    %>
    <form action="/CSE135/analytics" method="post">
      <input type="hidden" name="action" value="restart">
      <input type="submit" value="Start Over">
    </form>
    <% } //end if %>    
   </div>
  </body>
</html>