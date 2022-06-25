using Bogus;
using Bookvault.Book.API.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Bookvault.Book.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookController : Controller
    {
        private readonly ILogger<BookController> _logger;
        private readonly BookContext _context;

        public BookController(ILogger<BookController> logger, BookContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet("/books",Name = "GetBooks")]
        public ActionResult<List<Book>> GetBooks()
        {
            try
            {
                _logger.LogInformation("Retrieving all books");

                var bookId = 0;
                var books = new Faker<Book>()
                    .StrictMode(true)
                    .RuleFor(b => b.Id, (fake) => bookId++)
                    .RuleFor(b => b.Title, (fake) => fake.Commerce.ProductName())
                    .RuleFor(b => b.Category, (fake) => fake.PickRandom<string>(new List<string> { "Romance", "Fiction", "Sci-Fi", "Non-Fiction", "Biography", "Education", "Thriller" }))
                    .RuleFor(b => b.Author, (fake) => fake.PickRandom<string>(new List<string> { "Joe Bloggs", "Jane Smith", "Sky Blue", "Lisa Marcs", "Will Johns", "Don Small", "Arthur Morgan", "Michael Townley", "Ashley Smith" }))
                    .RuleFor(b => b.Price, (fake) => fake.Random.Decimal(9.99m, 17.99m))
                    .Generate(1);

                return new OkObjectResult(books);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(GetBooks)}: {ex.Message}");
                throw;
            }      
        }

        [HttpGet("/books/{id:int}", Name = "GetBookById")]
        public async Task<ActionResult<Book>> GetBookById(long id)
        {
            try
            {
                var book = await _context.Books.FindAsync(id);

                if (book is null)
                {
                    return NotFound();
                }

                return new OkObjectResult(book);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(GetBookById)}: {ex.Message}");
                throw;
            }
        }

        [HttpPost("/books", Name = "CreateBook")]
        public async Task<ActionResult<Book>> PostBook(Book book)
        {
            try
            {
                _context.Books.Add(book);
                await _context.SaveChangesAsync();

                return new OkObjectResult(book);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(PostBook)}: {ex.Message}");
                throw;
            }
        }

        [HttpPut("/books/{id:int}", Name = "UpdateBook")]
        public async Task<IActionResult> UpdateBookById(long id, Book book)
        {
            try
            {
                if (id != book.Id)
                {
                    return BadRequest();
                }

                var bookToUpdate = await _context.Books.FindAsync(id);
                if (bookToUpdate is null)
                {
                    return NotFound();
                }

                bookToUpdate.Title = book.Title;

                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(UpdateBookById)}: {ex.Message}");
                throw;
            }

            return NoContent();
        }

        [HttpDelete("/books/{id:int}", Name = "DeleteBook")]
        public async Task<IActionResult> DeleteBookById(long id)
        {
            try
            {
                var bookToDelete = await _context.Books.FindAsync(id);

                if (bookToDelete is null)
                {
                    return NotFound();
                }

                _context.Books.Remove(bookToDelete);
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(DeleteBookById)}: {ex.Message}");
                throw;
            }
        }
    }
}
