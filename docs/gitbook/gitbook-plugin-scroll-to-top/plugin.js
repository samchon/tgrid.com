require(["gitbook"], function (gitbook) 
{
    gitbook.events.bind("page.change", function() 
    {
        if (window.location.href.indexOf("#") === -1)
        {
            document.getElementsByClassName("book-body")[0].scrollTo(0, 0);
            document.getElementsByClassName("body-inner")[0].scrollTo(0, 0);
        }
    });
});
