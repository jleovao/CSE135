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
    <title>Home Page</title>
  </head>
  <body>
  	<div class="container">
      <div class ="header"><h1>Home Page</h1></div>
      <%
      if(name!=null){
        out.println("<h4>Hello, "+name+"!</h4>");
      }
      else{
        response.sendRedirect("/CSE135/redirectlogin");
      }
      %>
      
      <div class="nav">
        <ul>
          <%
          if(role.equals("owner")){
            out.println("<li><a href=\"/CSE135/categories\">Categories Page(owners)</a></li>"+
                        "<li><a href=\"/CSE135/products\">Products Page(owners)</a></li>"+
                        "<li><a href=\"/CSE135/similar_products\">Similar Products(owners)</a></li>"+
                        "<li><a href=\"/CSE135/analytics\">Sales Analytics(owners)</a></li>");
          }
          %>
          <li><a href="/CSE135/analytics">Sales Analytics (Owners)</a></li>
          <li><a href="/CSE135/similar_products">Similar Products Page</a></li>
          <li><a href="/CSE135/browsing">Product Browsing Page</a></li>
          <li><a href="/CSE135/order">Product Order Page</a></li>
          <li><a href="/CSE135/buy">Buy Shopping Cart</a></li>
          <li><a href="/CSE135/buyOrders.jsp">Buy Order</a></li>

        </ul>
      </div>
      <%
      if(role.equals("customer")){
        response.sendRedirect("/CSE135/browsing");
      }
      %>

    </div>
  </body>
</html>