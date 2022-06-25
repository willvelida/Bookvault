using Microsoft.EntityFrameworkCore;

namespace Bookvault.Book.API.Models
{
    public class BookContext : DbContext
    {
        public BookContext(DbContextOptions<BookContext> options) : base(options)
        {

        }

        public DbSet<Book> Books { get; set; } = null;
    }
}
