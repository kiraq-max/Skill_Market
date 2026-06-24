<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Welcome page: redireziona automaticamente alla pagina di login
    response.sendRedirect(request.getContextPath() + "/login");
%>
