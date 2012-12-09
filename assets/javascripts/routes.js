function project_url(){
	return "/projects/";
}

function project_url(project_id) {
	return projects_url() + project_id + "/";
}

function project_kanbans_url(project_id){
	return project_url(project_id) + "kanbans/";
}

function project_kanbans_url(project_id,kanban_id){
	return project_kanbans_url(project_id) + kanband_id + "/";
}

function project_kanban_wips_url(project_id,kanband_id){
	return project_kanbans_url(project_id,kanband_id) + "wips";
}
