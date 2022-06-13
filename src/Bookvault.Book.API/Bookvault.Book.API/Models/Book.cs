namespace Bookvault.Book.API
{
    public class Book
    {
        public string BookId => Guid.NewGuid().ToString();
        public string Title { get; set; }
    }
}
