<%@include file="/libs/foundation/global.jsp" %>

<%@ page import="java.util.*,
                 javax.jcr.Node,
                 com.be.ictdynamic.target.NodeBean, 
                 com.day.cq.commons.TidyJSONWriter,
				 com.day.cq.i18n.I18n"
%>

<%@ include file="/libs/foundation/global.jsp" %>

<%
    log.info("IctDynamic>>>test3.jcr: retrieving entries from JCR started");

    String jcrPath = (String)request.getParameter("jcrPath");
    log.info("IctDynamic>>>test3.jcr: retrieving entries from JCR, jcrPath = " + jcrPath);

    com.be.ictdynamic.target.JCRTargetInterface jcrTargetInterface = sling.getService(com.be.ictdynamic.target.JCRTargetInterface.class);
    ArrayList<NodeBean> nodeBeanArrayList = jcrTargetInterface.getNodes(jcrPath);
    log.info("IctDynamic>>>test3.jcr: entries retrieved from JCR, jcrPath.size = " + nodeBeanArrayList.size());

    try
    {
        TidyJSONWriter writer = new TidyJSONWriter(response.getWriter());
        writer.setTidy(false);

        writer.array();

        for (int i = 0; i < nodeBeanArrayList.size(); i++) {
            // log.info("IctDynamic>>>writing entry with index " + i + " and NodeId " + nodeBeanArrayList.get(i).getNodeId());
            writer.object();
            writer.key("NodeId").value(nodeBeanArrayList.get(i).getNodeId());
            writer.key("ResourceType").value(nodeBeanArrayList.get(i).getNodeResourceType());
            writer.key("ModificationDate").value(nodeBeanArrayList.get(i).getLastModified());
            writer.endObject();
        }     

        writer.endArray();

    }
    catch (Exception e)
    {
        log.error("IctDynamic>>> Exception Occured in test3.jcr.jsp. Exception: " + e.getMessage());
    }

    log.info("IctDynamic>>>test3.jcr: retrieving entries from JCR completed");
%> 

