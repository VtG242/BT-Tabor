function go(form,burl)
{
    x=form.year.selectedIndex;
    url=burl+"?year="+form.year[x].value;
    window.location=url;
}
