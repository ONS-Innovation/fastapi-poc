
from fastapi import APIRouter
from pydantic import BaseModel
from typing import Any

router = APIRouter(prefix="/technologies", tags=["technologies"])

# In-memory storage for technologies
# In a real application, this would be replaced with a database or persistent storage.
# This list will be reset every time the application restarts.
technologies = []

class Technology(BaseModel):
    name: str
    description: str


@router.get("")
async def get_technologies(idx: int = None, name: str = None) -> dict[str, list[Technology]]:
    """Get a list of technologies.

    Args:
        idx (int, optional): The index of the technology to filter by. Defaults to None.
        name (str, optional): The name of the technology to filter by. Defaults to None.

    Returns:
        dict: A dictionary containing a list of technologies.
    """

    if idx is not None:
        return {"technologies": [technologies[idx]]}

    if name:
        filtered_technologies = [tech for tech in technologies if tech.name == name]
        return {"technologies": filtered_technologies}

    return {"technologies": technologies}


@router.post("")
async def create_technology(technology: Technology) -> dict:
    technologies.append(technology)
    return {
        "message": "Technology created successfully",
        "technology": technology
    }


@router.get("/{technology_name}")
async def get_technology(technology_name: str) -> dict[str, Any]:
    """Get a single technology by name.

    Args:
        technology_name (str): The name of the technology to retrieve.

    Returns:
        dict: A dictionary containing the technology if found, or an error message. This includes the index of the technology in the list.
    """
    technology = next((tech for tech in technologies if tech.name == technology_name), None)
    index = next((i for i, tech in enumerate(technologies) if tech.name == technology_name), None)
    if technology:
        return {
            "technology": technology,
            "index": index
        }
    return {"error": "Technology not found"}


@router.delete("/{technology_index}")
async def delete_technology(technology_index: int) -> dict[str, Any]:
    """Delete a technology by index.

    Args:
        technology_index (int): The index of the technology to delete.

    Returns:
        dict: A dictionary containing a success message or an error message.
    """
    if 0 <= technology_index < len(technologies):
        deleted_technology = technologies.pop(technology_index)
        return {"message": "Technology deleted successfully", "technology": deleted_technology}
    return {"error": "Technology not found"}
