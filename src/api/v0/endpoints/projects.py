from fastapi import APIRouter
from pydantic import BaseModel
from typing import Any

router = APIRouter(prefix="/projects", tags=["projects"])

# In-memory storage for projects
# In a real application, this would be replaced with a database or persistent storage.
# This list will be reset every time the application restarts.
projects = []

class Project(BaseModel):
    name: str
    description: str

@router.get("")
async def get_projects(idx:int = None, name: str = None) -> dict[str, list[Project]]:
    """Get a list of projects.

    Args:
        idx (int, optional): The index of the project to filter by. Defaults to None.
        name (str, optional): The name of the project to filter by. Defaults to None.

    Returns:
        dict: A dictionary containing a list of projects.
    """

    if idx is not None:
        print(type(projects[idx]))
        return {"projects": [projects[idx]]}

    if name:
        filtered_projects = [project for project in projects if project.name == name]
        return {"projects": filtered_projects}

    return {"projects": projects}

@router.post("")
async def create_project(project: Project) -> dict:
    projects.append(project)
    return {
        "message": "Project created successfully",
        "project": project
    }

@router.get("/{project_name}")
async def get_project(project_name: str) -> dict[str, Any]:
    """Get a single project by name.

    Args:
        project_name (str): The name of the project to retrieve.

    Returns:
        dict: A dictionary containing the project if found, or an error message. This includes the index of the project in the list.
    """
    project = next((proj for proj in projects if proj.name == project_name), None)
    index = next((i for i, proj in enumerate(projects) if proj.name == project_name), None)
    if project:
        return {
            "project": project,
            "index": index
        }
    return {"error": "Project not found"}

@router.delete("/{project_index}")
async def delete_project(project_index: int) -> dict[str, Any]:
    """Delete a project by index.

    Args:
        project_index (int): The index of the project to delete.

    Returns:
        dict: A dictionary containing a success message or an error message.
    """
    if 0 <= project_index < len(projects):
        deleted_project = projects.pop(project_index)
        return {"message": "Project deleted successfully", "project": deleted_project}
    return {"error": "Project not found"}
