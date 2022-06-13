using Bogus;
using Microsoft.AspNetCore.Mvc;

namespace Bookvault.Book.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookController : Controller
    {
        private readonly ILogger<BookController> _logger;

        public BookController(ILogger<BookController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetBooks")]
        public ActionResult<List<Book>> Get()
        {
            var books = new Faker<Book>()
                .StrictMode(true)
                .RuleFor(b => b.BookId, (fake) => Guid.NewGuid().ToString())
                .RuleFor(b => b.Title, (fake) => fake.Commerce.ProductName())
                .Generate(10);

            return new OkObjectResult(books);
        }
    }
}
