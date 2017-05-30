<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    import="java.util.ArrayList" pageEncoding="ISO-8859-1"%>
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
    int rowlimit=20;
    int collimit=10;
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
    ArrayList<String> catlist = new ArrayList<String>();
    String rows;
    String order;
    String action=null;
    String filter;
    String filterquery;
    int ind=0;
    int countrow;
    int countcol;
    boolean showtable=true;
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
      countrow= countrow+rowlimit;
      session.setAttribute("countrow", countrow);
      session.setAttribute("tableflag",false);
    }
    if(action!=null && action.equals("nextcolumn")){
      countcol=countcol+collimit;
      session.setAttribute("countcol", countcol);
      session.setAttribute("tableflag",false);
    }
    if(action!=null && action.equals("start")){
      session.setAttribute("customerstate", request.getParameter("customerstate"));
      session.setAttribute("orderby",request.getParameter("orderby"));
      countcol =0;
      countrow=0;
      session.setAttribute("countrow", 0);
      session.setAttribute("countcol", 0);
    }
    if(action!=null && action.equals("categoryfilter")){
      session.setAttribute("selectfilter", request.getParameter("filterdrop")); 
    }
    if(action!=null && action.equals("restart")){
      session.removeAttribute("customerstate");
      session.removeAttribute("orderby");
      session.removeAttribute("selectfilter");
      session.removeAttribute("tableflag");
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
    try{
      if (session.getAttribute("selectfilter")!=null || !session.getAttribute("selectfilter").equals("")){
        filterquery="where p.category_name='"+(String)(session.getAttribute("selectfilter"))+"' ";
        filter=(String)(session.getAttribute("selectfilter"));
      }else {
        filter="";
        filterquery="";
      }
      if (session.getAttribute("selectfilter")!=null && session.getAttribute("selectfilter").equals("All")){
        filter="";
        filterquery="";
      }
    }catch(Exception e){
      filter="";
      filterquery="";
    }
    try{
      if (session.getAttribute("tableflag")!=null || !session.getAttribute("tableflag").equals("")){
        showtable=(Boolean)(session.getAttribute("tableflag"));
      }else {
        showtable=true;
      }
    } catch (Exception e) {
      showtable=true;
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
    <!-- choose row and column -->
    <%if(showtable) {%>
    <table>
      <tr>
        <form action="/CSE135/analytics" method="post">
          <input type="hidden" name="action" value="start">
          <td>Rows Column:
            <select name="customerstate">
              <% if (rows.equals("")||rows.equals("customer")){ %>
                <option value="customer">Customer</option>
              <%} %>
              <option value="state">State</option>
              <% if (rows.equals("state")){ %>
                <option value="customer">Customer</option>
              <%} %>
            </select>
          </td>
          <td>Order By:
            <select name="orderby">
              <% if (order.equals("")||order.equals("alphabetical")){ %>
                <option value="alphabetical">Alphabetical</option>
              <%} %>
              <option value="top-k">Top-K</option>
              <% if (order.equals("top-k")){ %>
                <option value="alphabetical">Alphabetical</option>
              <%} %>
            </select>
          </td>
          <td>
            <input type="submit" value="Run Query">
          </td>
        </form>
      </tr>
    </table> 
    
    <%
    }
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
      
      %>      
      <!-- category filter -->
      <table>
        <tr>
          <td>Category Filter: </td>
          <td>
            <% 
            rs1=stmt.executeQuery("select category_name from categories");
            while(rs1.next()){
              catlist.add(rs1.getString("category_name"));
            }
            %>
            <form action="/CSE135/analytics" method="post">
              <input type="hidden" name="action" value="categoryfilter">
              <select name="filterdrop">
              <%
                if(filter.equals("")||filter.equals("All")){
                  %>
                  <option value="All">All</option>
                  <%
                  for(String check:catlist){
                    %>
                    <option value=<%=check%>><%=check%></option>
                    <%
                  }
                }else{
                  %>
                  <option value=<%=filter%>><%=filter%></option>
                  <%
                  for(String check:catlist){
                    if(!check.equals(filter)){
                    %>
                    <option value=<%=check%>><%=check%></option>
                    <%
                    }
                  }
                  %>
                  <option value="All">All</option>
                  <%
                }
              %>
              </select>
              <input type="submit" value="Filter">
            </form>
          </td>
        </tr>
      </table>
      <!-- 2-d chart that displays report -->
      
      <%
      if ((!rows.equals("") && !order.equals(""))){  
        %>
        Displaying rows <%=countrow+1%> - <%=countrow+rowlimit %>
        <br>
        Displaying columns <%=countcol+1 %> - <%=countcol+collimit %>
        <%
        if(order.equals("alphabetical")){
          rs2=stmt2.executeQuery("select p.product_name from product p "+filterquery+" order by p.product_name limit "+collimit+" offset "+countcol);
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

              String[] prodarray = new String[collimit];
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
          rs3=stmt3.executeQuery("select p.product_name from product p "+filterquery+" order by p.product_name limit "+collimit+" offset "+(countcol+collimit));
          if(rs3.next()){
            showcolbut= true;
          }
          //if alphabetical customer
          if(rows.equals("customer")){
          rs1=stmt.executeQuery("select name from users order by name limit "+rowlimit+" offset "+countrow);
            while (rs1.next()){
              %>
              <tr>
                <%
                  String customername = rs1.getString("name");
                  %>
                  <td><%=customername %></td>
                  <%             
                  for(int i=0;i<prodarray.length;i++){
                    rs4=stmt4.executeQuery("select  sum(i.price) from items i, carts c, product p where c.purchase_date is not null and i.id=c.id and c.name='"+customername+"' and p.sku=i.sku and p.product_name='"+prodarray[i]+"' group by i.sku");
                    double price = 0;
                    double total = 0;
                    if(prodarray[i]!=null){
                      while(rs4.next()){
                        price=rs4.getDouble(1);
                        total=total +price;
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
            rs5=stmt5.executeQuery("select name from users order by name limit "+rowlimit+" offset "+(countrow+rowlimit));
            if(rs5.next()){
              showrowbut= true;
            }
          }//end if alphabet customer
          //if alphabetical state
          if(rows.equals("state")){
            rs1=stmt.executeQuery("select state from users group by state order by state limit "+rowlimit+" offset "+countrow);
            while (rs1.next()){
              %>
              <tr>
                <%
                  String statename = rs1.getString("state");
                  %>
                  <td><%=statename %></td>
                  <%             
                  for(int i=0;i<prodarray.length;i++){
                    rs4=stmt4.executeQuery("select sum(i.price) from users u, items i, carts c, product p where c.purchase_date is not null and i.id=c.id and c.name=u.name and u.state='"+statename+"' and p.sku=i.sku and p.product_name='"+prodarray[i]+"' group by i.sku");
                    double quant = 0;
                    double price = 0;
                    double total = 0;
                    if(prodarray[i]!=null){
                      while(rs4.next()){
                        price=rs4.getDouble(1);
                        total=total +(price);
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
            rs5=stmt5.executeQuery("select state from users group by state order by state limit "+rowlimit+" offset "+(countrow+rowlimit));
            if(rs5.next()){
              showrowbut= true;
            }
          }//end if alphabet state
          %>
          </table>
          <%         
        } //end if alphabetical
        // if top-k
        if(order.equals("top-k")){
          if (!filterquery.equals("")){
            filterquery = "and p.category_name='"+filter+"'";
          }

          rs1=stmt.executeQuery("select p.sku,sum(i.price) as totalsum from items i,product p where p.sku=i.sku "+filterquery+" group by p.sku union (select p.sku, 0 as totalsum from product p where p.sku not in( select i.sku from items i) "+filterquery+") order by totalsum desc limit "+collimit+" offset "+countcol);
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
              String[] prodarray=new String[collimit];
              while(rs1.next()){
                String skuorder = rs1.getString("sku");
                rs2=stmt2.executeQuery("select p.product_name from product p where p.sku='"+skuorder+"'" );
                if(rs2.next()){
                  System.out.println(ind+" "+rs2.getString("product_name"));
                  prodarray[ind]=rs2.getString("product_name");
                }
                %>
                <td><%=prodarray[ind] %></td>
                <%
                ind++;
                }
              %>
            </tr>
            <%
            rs3=stmt3.executeQuery("select p.sku,sum(i.price) as totalsum from items i,product p where p.sku=i.sku "+filterquery+" group by p.sku union (select p.sku, 0 as totalsum from product p where p.sku not in( select i.sku from items i)"+filterquery+") order by totalsum desc limit "+collimit+" offset "+(countcol+collimit));
            if(rs3.next()){
              showcolbut= true;
            }
            if(rows.equals("customer")){
              rs4 = stmt4.executeQuery("select c.name, sum(i.price) from carts c,items i,product p where c.id=i.id and p.sku=i.sku "+filterquery+" group by c.name union (select u.name,0 from users u where u.name not in (select c.name from carts c)) order by 2 desc limit "+rowlimit+" offset "+countrow);
              while(rs4.next()){
                %>
                <tr>
                  <%
                    String customername = rs4.getString("name");
                    %>
                    <td><%=customername %></td>
                    <%             
                    for(int i=0;i<prodarray.length;i++){
                      rs5=stmt5.executeQuery("select  sum(i.price) from items i, carts c, product p where c.purchase_date is not null and i.id=c.id and c.name='"+customername+"' and p.sku=i.sku and p.product_name='"+prodarray[i]+"' group by i.sku");
                      double price = 0;
                      double total = 0;
                      if(prodarray[i]!=null){
                        while(rs5.next()){
                          price=rs5.getDouble(1);
                          total=total +(price);
                        }
                        %>
                        <td><%=total %></td>
                        <%
                      }
                    }
                  %>
                </tr>
                <%
              }//end while get customer name
              rs1=stmt.executeQuery("select c.name, sum(i.price) from carts c,items i,product p where c.id=i.id and p.sku=i.sku "+filterquery+" group by c.name union (select u.name,0 from users u where u.name not in (select c.name from carts c)) order by 2 desc limit "+rowlimit+" offset "+(countrow+rowlimit));
              if(rs1.next()){
                showrowbut= true;
              }
            }//end if customer top-k
            
            if(rows.equals("state")){
              rs4=stmt4.executeQuery("select u.state, sum(i.price) from carts c, users u,items i, product p where u.name=c.name and c.id=i.id and p.sku=i.sku "+filterquery+" group by u.state union (select u.state,0 from users u where u.state not in (select u.state from users u,carts c where u.name = c.name)) order by 2 desc limit "+rowlimit+" offset "+countrow);
              while(rs4.next()){
                %>
                <tr>
                  <%
                    String statename = rs4.getString("state");
                    %>
                    <td><%=statename %></td>
                    <%             
                    for(int i=0;i<prodarray.length;i++){
                      rs5=stmt5.executeQuery("select sum(i.price) from users u, items i, carts c, product p where c.purchase_date is not null and i.id=c.id and c.name=u.name and u.state='"+statename+"' and p.sku=i.sku and p.product_name='"+prodarray[i]+"' group by i.sku");
                      double quant = 0;
                      double price = 0;
                      double total = 0;
                      if(prodarray[i]!=null){
                        while(rs5.next()){
                          price=rs5.getDouble(1);
                          total=total +(price);
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
              rs1=stmt.executeQuery("select u.state, sum(i.price) from carts c, users u,items i, product p where u.name=c.name and c.id=i.id and p.sku=i.sku "+filterquery+" group by u.state union (select u.state,0 from users u where u.state not in (select u.state from users u,carts c where u.name = c.name)) order by 2 desc limit "+rowlimit+" offset "+(countrow+rowlimit));
              if(rs1.next()){
                showrowbut= true;
              }
            }
            %>
          </table>          
          <%        
        }//end if top-k
      }
      %>
      </table>
      
      <%
    }catch(Exception e){      
      e.printStackTrace();
    }
    //close statements
    finally{
      try {
        if(rs1 != null) {
          rs1.close();
        }
        if(stmt != null) {
          stmt.close();
        }
        if(rs2 != null) {
          rs2.close();
        }
        if(stmt2 != null) {
          stmt2.close();
        }
        if(rs3 != null) {
          rs3.close();
        }
        if(stmt3 != null) {
          stmt3.close();
        }
        if(rs4 != null) {
          rs4.close();
        }
        if(stmt4 != null) {
          stmt4.close();
        }
        if(rs5 != null) {
          rs5.close();
        }
        if(stmt5 != null) {
          stmt5.close();
        }
      } 
      catch(Exception e) {
        e.printStackTrace();
      }
    }
    %>

    
    <%
    if((!rows.equals("") && !order.equals(""))){
    %>
    <!-- next X buttons -->
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
    <!-- start over button -->
    <form action="/CSE135/analytics" method="post">
      <input type="hidden" name="action" value="restart">
      <input type="submit" value="Start Over">
    </form>
    <% } //end if %>    
   </div>
  </body>
</html>