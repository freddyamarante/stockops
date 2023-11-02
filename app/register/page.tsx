import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { ChevronLeft } from 'lucide-react'
import RegisterForm from '@/components/RegisterForm'

export default function Register() {
  return (
    <div className="flex-1 flex flex-col w-full px-4 sm:max-w-lg justify-center gap-2">
      <Button
        asChild
        variant="outline"
        size="sm"
        className="w-fit sm:absolute sm:mb-0 my-2 left-8 top-8"
      >
        <Link href="/">
          <ChevronLeft className="mr-2 h-4 w-4" /> Back
        </Link>
      </Button>

      <RegisterForm />
    </div>
  )
}
