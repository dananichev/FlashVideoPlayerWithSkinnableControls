
function onButtonClick() 
{
	document.getElementById("videoplayer").htmlPlayPauseClick();
	
	var curLabel = document.getElementById("playPauseBtn").innerHTML;
    if (curLabel == "Play") 
	{
		document.getElementById("playPauseBtn").innerHTML = "Pause"
	}
	else
	{
		document.getElementById("playPauseBtn").innerHTML = "Play";
	}
}